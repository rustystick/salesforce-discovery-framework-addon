global with sharing class Assessmentx implements Callable{
    static final String OMNI_METHOD_GET_RESPONSE = 'getResponse';
    static final String OMNI_METHOD_SAVE_RESPONSE = 'saveResponse';

    @TestVisible
    static IDataTransformer testDataTransformerOverride;

    @TestVisible
    static IAssessmentService testServiceOverride;

    @AuraEnabled(cacheable=true)
    public static Object getAssessmentResponse(Id assessmentId){
        try {
            return new Assessmentx().getResponse(assessmentId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @TestVisible
    IAssessmentService service;
    @TestVisible
    IDataTransformer transformer;

    public Assessmentx() {
        this.service = testServiceOverride ?? new AssessmentService();
        this.transformer = testDataTransformerOverride ?? new AssessmentResponseTransformer();
    }

    public Object getResponse(Id assessmentId) {
        return this.service.getResponse(assessmentId);
    }


    /**
     * @description implements the callable interface for omniscript
     * @param  methodName method name that OS calls
     * @param  args       arguments
     * @return            boolean indicating if the call was successful or not
     */ 
    global Object call(String methodName, Map<String, Object> args) {
        return invokeMethod(methodName, (Map<String, Object>)args.get('input'), (Map<String, Object>)args.get('output'), (Map<String, Object>)args.get('options'));
    }

    private Boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outmap, Map<String, Object> options) {
        String assessmentId;
        // this handles either direct call from OS or a call from DR Function
        if(inputMap.containsKey('arguments')) {
            assessmentId = (String)((List<Object>)inputMap.get('arguments'))[0];
        } 
        if(inputMap.containsKey('assessmentId')) {
            assessmentId = (String)inputMap.get('assessmentId');
        }
        if(methodName == OMNI_METHOD_GET_RESPONSE && assessmentId != null) {
            String locale = UserInfo.getLanguage().contains('en') ? 'en' : 'fr';
            AssessmentResponseTransformer.Input input = new AssessmentResponseTransformer.Input(locale, service.getResponse(assessmentId));
            outmap.put('result', this.transformer.transform(input));
            return true;
        }
        return false;
    }
}