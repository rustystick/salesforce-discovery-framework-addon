@IsTest
public class AssessmentServiceTest {
    static Id dummyId = '0jNAu0000002mJtMAI';

    @IsTest
    static void getResponseShouldReturnAssessmentResponseSummary() {
        // ARRANGE
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();

        AssessmentQuestionSetting.getInstance()
            .settingsCache.put(
                AssessmentQuestionSetting.PURPOSE_NA_CRITERIA,
                new List<Assessment_Question_Setting__mdt>{
                    new Assessment_Question_Setting__mdt(
                        Driving_Question_Name__c = 'field1',
                        Driven_Question_Name__c = 'field2',
                        Criteria_Value__c = 'Value 1',
                        Purpose__c = AssessmentQuestionSetting.PURPOSE_NA_CRITERIA
                    )
                }
            );

        AssessmentService.omniProcessKeyOverride = 'target';
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };

        // ACT
        Object response = new AssessmentService().getResponse(dummyId);

        // ASSERT
        Assert.isNotNull(response, 'response should not be null');
    }

    @IsTest
    static void getResponseShouldReturnNAFieldsPerSetting() {
        // ARRANGE
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();

        AssessmentQuestionSetting.getInstance()
            .settingsCache.put(
                AssessmentQuestionSetting.PURPOSE_NA_CRITERIA,
                new List<Assessment_Question_Setting__mdt>{
                    new Assessment_Question_Setting__mdt(
                        Driving_Question_Name__c = 'field1',
                        Driven_Question_Name__c = 'field2',
                        Criteria_Value__c = 'Value 1',
                        Purpose__c = AssessmentQuestionSetting.PURPOSE_NA_CRITERIA
                    )
                }
            );

        responseSummary.get('target').get('step1').value.get('field2').value = '';
        AssessmentService.omniProcessKeyOverride = 'target';
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };

        // ACT
        Object field2Value = getProperty(
                new AssessmentService().getResponse(dummyId),
                new List<String>{ 'step1', 'value', 'field2', 'isNa' }
            );
            

        // ASSERT
        Assert.isInstanceOfType(field2Value, Boolean.class, 'field 2 should be string type');
        Assert.isTrue((Boolean)field2Value, 'field2 value should be NA per field value dependency setting');
    }

    @IsTest
    static void getResponseShouldReturnResponseWithDataType(){
        // ARRANGE
        String expectedDataType = 'Text';
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();
        AssessmentService.omniProcessKeyOverride = 'target';
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };
        
        insert new AssessmentQuestion(Name='Question', DeveloperName='field1', DataType=expectedDataType, QuestionCategory='Demographic');

        // ACT
        String response = (String)getProperty(new AssessmentService().getResponse(dummyId), new List<String>{'step1', 'value','field1', 'dataType'});
        String negativeResponse = (String)getProperty(new AssessmentService().getResponse(dummyId), new List<String>{'step1', 'value','field2', 'dataType'});

        // ASSERT
        Assert.isNull(negativeResponse, 'non-question should have a null dataType');
        Assert.isNotNull(response, 'data type should not be null');
        Assert.areEqual(expectedDataType, response, 'data type should be text');
    }
    
    @IsTest
    static void getResponseShouldReturnResponseWithFormulaDataTypeIfDataTypeIsFormula(){
        // ARRANGE
        String expectedDataType = 'Text';
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();
        AssessmentService.omniProcessKeyOverride = 'target';
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };
        
        insert new AssessmentQuestion(Name='Question', DeveloperName='field1', DataType='Formula', FormulaResponseDataType=expectedDataType, QuestionCategory='Demographic');

        // ACT
        String response = (String)getProperty(new AssessmentService().getResponse(dummyId), new List<String>{'step1', 'value','field1', 'dataType'});

        // ASSERT
        Assert.isNotNull(response, 'data type should not be null');
        Assert.areEqual(expectedDataType, response, 'data type should be text');
    }

    @isTest
    static void getResponseShouldSkipFormulaFieldsWhichHaveHideSetToTrue() {
        // ARRANGE
        String field1Name = 'field1';
        String step1Name = 'step1';
        String omniKeyOverride = 'target';

        OmniProcess assessmentOmniScript = new OmniProcess(Type='dummyType', SubType='dummySubType', Language='language', Name='dumm');
        insert assessmentOmniScript;
        insert new OmniProcessElement(OmniProcessId=assessmentOmniScript.Id, Type='Formula', Name=field1Name, PropertySetConfig=JSON.serialize(new Map<String, Boolean>{'hide'=>true}));
        AssessmentService.assessmentOverride = new Assessment(Name = 'test', OmniProcessId = assessmentOmniScript.Id);
        AssessmentService.omniProcessKeyOverride = omniKeyOverride;
        
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };

        // ACT
        Map<String, Object> step1 = (Map<String, Object>)getProperty(new AssessmentService().getResponse(dummyId), new List<String>{step1Name, 'value'});

        // ASSERT
        Assert.isTrue(responseSummary.get(omniKeyOverride).get(step1Name).value.containsKey(field1Name), 'there should be a field1 in the response before processing');
        Assert.isFalse(step1.containsKey(field1Name), 'field1 should be removed from the response');
    }

    @IsTest
    static void getResponseShouldReturnResponseWithEditBlock(){
        // ARRANGE
        String expectedDataType = 'EditBlock';
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();
        AssessmentService.omniProcessKeyOverride = 'target';
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };
        
        insert new AssessmentQuestion(Name='Question', DeveloperName='field9', DataType='EditBlock', QuestionCategory='Demographic');

        // ACT
        String response = (String)getProperty(new AssessmentService().getResponse(dummyId), new List<String>{'step3', 'value','field9', 'dataType'});

        // ASSERT
        Assert.isNotNull(response, 'data type should not be null');
        Assert.areEqual(expectedDataType, response, 'data type should be EditBlock');
    }

    @IsTest
    static void getResponseShouldReturnNAWhenLeafNodeIsInArray() {
        // ARRANGE
        Map<String, Map<String, StepElement>> responseSummary = generateDummyResponseSummary();
        AssessmentService.omniProcessKeyOverride = 'target';
        
        AssessmentQuestionSetting.getInstance()
            .settingsCache.put(
                AssessmentQuestionSetting.PURPOSE_NA_CRITERIA,
                new List<Assessment_Question_Setting__mdt>{
                    new Assessment_Question_Setting__mdt(
                        Driving_Question_Name__c = 'field7',
                        Driven_Question_Name__c = 'field8',
                        Criteria_Value__c = 'value7',
                        Purpose__c = AssessmentQuestionSetting.PURPOSE_NA_CRITERIA
                    )
                }
            );

        List<Map<String, Leafelement>> arrVal = (List<Map<String, Leafelement>>)((ArrayElement)(responseSummary.get('target').get('step3').value.get('field9'))).value;
        arrVal[0].get('field8').value = '';
        arrVal[0].get('field7').value = 'value7';
        arrVal[1].get('field8').value = '';
        arrVal[1].get('field7').value = 'notValue7';
        
        AssessmentService.resultCache = new Map<Id, String>{ dummyId => JSON.serialize(responseSummary) };

        Object response = new AssessmentService().getResponse(dummyId);

        List<Object> objList = (List<Object>)getProperty(response, new List<String>{'step3', 'value', 'field9', 'value'});
        
        Assert.isTrue((Boolean)getProperty(objList[0], new List<String>{'field8', 'isNa'}), 'field 8 should be NA in this array index');
        Assert.isFalse((Boolean)getProperty(objList[1], new List<String>{'field8', 'isNa'}), 'field 8 should not be NA in this array index');
    }


    static Map<String, Map<String, StepElement>> generateDummyResponseSummary() {
        Map<String, Map<String, StepElement>> res = new Map<String, Map<String, StepElement>>();

        Map<String, StepElement> target = new Map<String, StepElement>();

        StepElement step1 = new StepElement('step1');
        Map<String, BaseElement> step1FieldValues = new Map<String, BaseElement>();
        step1.value = step1FieldValues;
        step1FieldValues.put('field3', new LeafElement('Field 3', 'Value 3'));
        step1FieldValues.put('field2', new LeafElement('Field 2', 'Value 2'));
        step1FieldValues.put('field1', new LeafElement('Field 1', 'Value 1'));

        StepElement step2 = new StepElement('step2');
        Map<String, BaseElement> step2FieldValues = new Map<String, BaseElement>();
        step2.value = step2FieldValues;
        step2FieldValues.put('field6', new LeafElement('Field 6', 'Value 6'));
        step2FieldValues.put('field5', new LeafElement('Field 5', 'Value 5'));
        step2FieldValues.put('field4', new LeafElement('Field 4', 'Value 4'));

        StepElement step3 = new StepElement('step3');
        Map<String, BaseElement> step3FieldValues = new Map<String, BaseElement>();
        step3.value = step3FieldValues;

        List<Map<String, LeafElement>> leafNodes = new List<Map<String, LeafElement>>{
            new Map<String, LeafElement>{
                'field8' => new LeafElement('Field 8', 'value8'),
                'field7' => new LeafElement('Field 7', 'value7')
            },
            new Map<String, LeafElement>{ 'field8' => new LeafElement('Field 8', ''), 'field7' => new LeafElement('Field 7', 'notValue7') }
        };
        // Note: order matters since we are serializing into a JSON. apex reverses order for whatever reason
        step3FieldValues.put('field9', new ArrayElement('Field 9', leafNodes));
        target.put('step3', step3);
        target.put('step2', step2);
        target.put('step1', step1);

        Map<String, StepElement> dummy = new Map<String, StepElement>();
        res.put('target', target);

        return res;
    }

    static Object getProperty(Object obj, List<String> path) {
        Map<String, Object> temp = (Map<String, Object>) obj;
        for (Integer i = 0; i < path.size() - 1; i++) {
            temp = (Map<String, Object>) temp.get(path[i]);
        }
        return temp.get(path[path.size() - 1]);
    }

    static void setProperty(Object obj, Object property, List<String> path) {
        Map<String, Object> temp = (Map<String, Object>) obj;
        for(Integer i = 0; i < path.size() - 1; i++) {
            temp = (Map<String, Object>) temp.get(path[i]);
        }
        temp.put(path[path.size() - 1], property);
    }

    // data model so we can more easily manipulate these
    class StepElement {
        public StepElement(String label) {
            this.label = label;
        }
        public String label;
        public Map<String, BaseElement> value;
    }

    abstract class BaseElement {
        public BaseElement(String value) {
            this.label = value;
        }
        public String label;
        // since apex doesn't have union type, we need this to emulate
        public Object value {
            get {
                return this.getValue();
            }
            set {
                this.setValue(value);
            }
        }
        protected abstract Object getValue();
        protected abstract void setValue(Object value);
    }

    class LeafElement extends BaseElement {
        public LeafElement(String label, String value) {
            super(label);
            this.xvalue = value;
        }
        transient public String xvalue;
        protected override Object getValue() {
            return this.xvalue;
        }
        protected override void setValue(Object value) {
            if (value instanceof String) {
                this.xvalue = (String) value;
            }
        }
    }

    class ArrayElement extends BaseElement {
        public ArrayElement(String label, List<Map<String, LeafElement>> value) {
            super(label);
            this.xvalue = value;
        }
        transient public List<Map<String, LeafElement>> xvalue;
        protected override Object getValue() {
            return this.xvalue;
        }
        protected override void setValue(Object value) {
            if (value instanceof List<Map<String, LeafElement>>) {
                this.xvalue = (List<Map<String, LeafElement>>) value;
            }
        }
    }
}