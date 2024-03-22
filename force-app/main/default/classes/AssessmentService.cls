public with sharing class AssessmentService implements IAssessmentService {
    public static final String NA = 'NA';
    static final String LABEL = 'label';

    @TestVisible
    static Map<Id, String> resultCache;


    public AssessmentService() {
        if (resultCache == null) {
            resultCache = new Map<Id, String>();
        }
    }

    // TODO: refactor reading response to separate class
    List<String> questionsToSkip = new List<String>();

    public Object getResponse(Id assessmentId) {
        // only reliable way of getting response in the correct order
        Object responseJson = JSON.deserializeUntyped(getInvocableActionResult(assessmentId));
        Map<String, Object> assessmentSummary = (Map<String, Object>) responseJson;
        Map<String, List<BaseElement>> context = new Map<String, List<BaseElement>>();
        Assessment assessment = getAssessment(assessmentId);
        populateSkipQuestionWithHiddenFormulaNames(assessment);
        system.debug(questionsToSkip);
        String omniProcessKey = getOmniProcessKey(assessment);
        dfs(assessmentSummary.get(omniProcessKey), '', context);
        addDataType(context);
        return assessmentSummary.get(omniProcessKey);
    }

    void addDataType(Map<String, List<BaseElement>> context) {
        for (String developerName : context.keySet()) {
        }
        for (AssessmentQuestion question : [
            SELECT Id, DataType, FormulaResponseDataType, DeveloperName
            FROM AssessmentQuestion
            WHERE DeveloperName IN :context.keySet()
        ]) {
            String dataType = question.DataType == 'Formula' ? question.FormulaResponseDataType : question.DataType;
            for(BaseElement baseElement : context.get(question.DeveloperName)){
                baseElement.dataType = dataType;
            }
        }
    }

    public String getInvocableActionResult(String assessmentId) {
        if (!resultCache.containsKey(assessmentId)) {
            List<Invocable.Action.Result> results = Invocable.Action.createStandardAction('getAssessmentResponseSummary').setInvocationParameter('assessmentId', assessmentId).invoke();
            resultCache.put(assessmentId, (String) results[0].getOutputParameters().get('assessmentResponseSummary'));
        }
        return resultCache.get(assessmentId);
    }

    /**
     * @description dfs in the response tree to do additional processing
     * @param  node    current node being processed
     * @param  key     key of the node
     * @param  context contains the pointer to context so it can be used // temp memory
     * @return         return value to be consumed by the function itself. for caller should just be considered always false
     */ 
    Boolean dfs(Object node, String key, Map<String, List<BaseElement>> context) {
        if(key != null && !context.containsKey(key)) {
            context.put(key, new List<BaseElement>());
        }

        Object currentNodeValue = getValueFromObject(node, 'value');

        if (currentNodeValue instanceof String) {
            Map<String, Object> castedNode = (Map<String, Object>) node;
            LeafElement leafElement = new LeafElement(node);
            context.get(key).add(leafElement);
            if(questionsToSkip.contains(key)) {
                // if the item should be skipped in the response
                return true;
            }
            if (String.isBlank(leafElement.value)) {
                checkNA(castedNode, key, context);
            }
        } else if (currentNodeValue instanceof List<Object>) {
            context.get(key).add(new EditBlockElement(node));
            for (Object oneNode : (List<Object>) currentNodeValue) {
                dfs(oneNode, null, context);
            }
        } else if (currentNodeValue instanceof Map<String, Object>) {
            context.get(key).add(new MaybeEditBlockElement(node));
            Map<String, Object> stepNode = (Map<String, Object>) currentNodeValue;
            for (String key1 : stepNode.keySet()) {
                Boolean toRemove = dfs(stepNode.get(key1), key1, context);
                // process the skipping by removing the value
                if(toRemove) {
                    stepNode.remove(key1);
                }
            }
        } else {
            Map<String, Object> castedNode = (Map<String, Object>) node;
            for (String key1 : castedNode.keySet()) {
                dfs(castedNode.get(key1), key1, context);
            }
        }
        return false;
    }

    void checkNA(Map<String, Object> node, String key, Map<String, List<BaseElement>> context) {
        //initialize it to false
        node.put('isNa', false);
        Map<String, Map<String, String>> naSettings = AssessmentQuestionSetting.getInstance().getNaValuesSettings();
        if (!naSettings.containsKey(key)) {
            return;
        }
        Set<String> drivingQuestionNames = naSettings.get(key).keySet();
        for (String drivingQuestionName : drivingQuestionNames) {
            List<BaseElement> elementArray = context.get(drivingQuestionName);
            // get the most recent entry in context
            LeafElement leaf = (LeafElement)elementArray[elementArray.size() - 1];
            if (leaf.value != naSettings.get(key).get(drivingQuestionName)) {
                continue;
            }
            // once node is set to NA we can return;
            node.put('isNa', true);
            return;
        }
    }

    @TestVisible
    private static List<String> questionsToSkipOverride = new List<String>();
    void populateSkipQuestionWithHiddenFormulaNames(Assessment assessment) {
        if(assessment == null) {
            questionsToSkip = questionsToSkipOverride;
            return;
        }
        for(OmniProcessElement element : [SELECT Id, PropertySetConfig, Name FROM OmniProcessElement WHERE OmniProcessId = :Assessment.OmniProcessId AND Type = 'Formula']) {
            Map<String, Object> config = (Map<String, Object>)JSON.deserializeUntyped(element.PropertySetConfig);
            if((Boolean)config.get('hide')) {
                questionsToSkip.add(element.Name);
            }
        }
    }

    Object getValueFromObject(Object obj, String key) {
        Map<String, Object> castedObj = (Map<String, Object>) obj;
        return castedObj.get(key);
    }

    // variable for unit test only
    @TestVisible
    private static String omniProcessKeyOverride;
    String getOmniProcessKey(Assessment assessment) {
        return omniProcessKeyOverride == null ? String.join(new List<String>{ assessment?.OmniProcess?.Type, assessment?.OmniProcess?.SubType, assessment?.OmniProcess?.Language }, '_')
            : omniProcessKeyOverride;
    }

    @TestVisible
    private static Assessment assessmentOverride;
    Assessment getAssessment(Id assessmentId) {
        List<Assessment> assessments = [SELECT OmniProcessId, OmniProcess.Type, OmniProcess.SubType, OmniProcess.Language FROM Assessment WHERE Id = :assessmentId];
        return assessments.size() > 0 ? assessmentOverride ?? assessments[0] : assessmentOverride;
    }

    abstract class BaseElement {
        Map<String, Object> elementReference;
        public BaseElement(Object element) {
            this.elementReference = (Map<String, Object>) element;
        }
        public String dataType {
            set {
                this.elementReference.put('dataType', value);
            }
        }
    }

    class EditBlockElement extends BaseElement{
        List<Object> value {
            get {
                return (List<Object>) this.elementReference.get('value');
            }
        }
        public EditBlockElement(Object element) {
            super(element);
        }
    }
    
    class MaybeEditBlockElement extends BaseElement{
        Map<String, Object> value {
            get {
                return (Map<String, Object>) this.elementReference.get('value');
            }
        }
        public MaybeEditBlockElement(Object element) {
            super(element);
        }
    }

    class LeafElement extends BaseElement {
        String value {
            get {
                return (String) this.elementReference.get('value');
            }
        }
        public LeafElement(Object element) {
            super(element);
        }
    }

}