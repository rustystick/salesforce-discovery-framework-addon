@IsTest
public class AssessmentTest {
    static String calledId;

    @IsTest
    static void getResponseShouldCallGetResponseFromAssessmentServiceWithIdPassedIn(){
        Id fakeId = '001Au00000G6giEIAR';
        Boolean returnValue = true;
        Assessmentx.testServiceOverride = new FakeAssessmentService(returnValue);
        Assessmentx assessment = new Assessmentx();
        Object result = assessment.getResponse(fakeId);
        Assert.areEqual(fakeId, calledId, 'getResponse from service should be called with the same Id');
        Assert.areEqual(returnValue, result, 'getResponse should pass through the return value from service\'s getResponse method');
    }

    @IsTest
    static void constructorWithoutParameterSetsDefaultServiceClass(){
        Assessmentx assessment = new Assessmentx();
        Assert.isInstanceOfType(assessment.service, AssessmentService.class, 'the default concrete service should be AssessmentService class');
        Assert.isInstanceOfType(assessment.transformer, AssessmentResponseTransformer.class, 'the default concrete transformer should be AssessmentREsponseTransformer');
    }

    @IsTest
    static void getAssessmentResponseShouldCallGetResponseFromAssessmentServiceWithIdPassedIn() {
        Boolean returnValue = true;
        Assessmentx.testServiceOverride = new FakeAssessmentService(returnValue);
        Assessmentx assessment = new Assessmentx();
        Id fakeId = '001Au00000G6giEIAR';
        Object result = Assessmentx.getAssessmentResponse(fakeId);
        Assert.areEqual(fakeId, calledId, 'getREsponse from service should be called with the same Id');
        Assert.areEqual(returnValue, result, 'getResponse should pass through the return value from service\'s getResponse method');
    }

    @IsTest
    static void getAssessmentResponseShouldThrowAuraHandledExceptionWhenThereIsException(){
        Assessmentx.testServiceOverride = new FakeAssessmentService(new CalloutException('ex'));
        Id fakeId = '001Au00000G6giEIAR';
        Exception caughtException;
        try {
            Assessmentx.getAssessmentResponse(fakeId);
        }catch(Exception ex) {
            caughtException = ex;
        }
        Assert.isInstanceOfType(caughtException, AuraHandledException.class, 'AuraHandledException should have been thrown');
    }

    @IsTest
    static void callgetResponseShouldExtractTheAssessmentIdFromInputArguments(){
        Id fakeId = '001Au00000G6giEIAR';
        Map<String, String> returnValue = new Map<String, String>();
        Assessmentx.testDataTransformerOverride = new FakeTransformer();
        Assessmentx.testServiceOverride = new FakeAssessmentService(returnValue);
        Assessmentx assessment = new Assessmentx();
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>{'arguments'=>new List<String>{fakeId}};
        
        assessment.call('getResponse', new Map<String, Object>{'input'=>input, 'output' => output, 'options' => options});
        Assert.areEqual(fakeId, calledId, 'assessmentId passed in via argument list should be used');

        calledId = '';
        Map<String, Object> input2 = new Map<String, Object>{'assessmentId' => fakeId};
        assessment.call('getResponse', new Map<String, Object>{'input' => input2, 'output' => output, 'options' => options});
        Assert.areEqual(fakeId, calledId, 'assessmentId passed in via input assessmentId parameter should be used');
    }

    @IsTest
    static void callgetResponseShouldPassTheLocaleAndCurrentDateTimeToDataweaveInputToGetGeneratedDateTimeOutput(){
        Id fakeId = '001Au00000G6giEIAR';
        Map<String, String> returnValue = new Map<String, String>();
        Assessmentx.testServiceOverride = new FakeAssessmentService(returnValue);
        FakeTransformer fakeTransformer = new FakeTransformer();
        Assessmentx.testDataTransformerOverride = fakeTransformer;
        Assessmentx assessment = new Assessmentx();
        
        Map<String, Object> output = new Map<String, Object>();
        Map<String, Object> options = new Map<String, Object>();
        Map<String, Object> input = new Map<String, Object>{'arguments'=>new List<String>{fakeId}};

        update new User(Id = UserInfo.getUserId(), LanguageLocaleKey = 'fr');
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            assessment.call('getResponse', new Map<String, Object>{'input' => input, 'output' => output, 'options' => options});
        }
        
        AssessmentResponseTransformer.Input transformerInput = fakeTransformer.inputReceived;
        Assert.areEqual('fr', transformerInput.locale, 'locale value should be send as input');
        Assert.isNotNull(transformerInput.generatedDateTime, 'generated date time should not be null');
        Assert.isInstanceOfType(transformerInput.generatedDateTime, DateTIme.class, 'generated date time should be set');
        Assert.areEqual(returnValue, transformerInput.payload, 'return value from getResponse should be sent to be transformed');
    }
    // TODO: test the DataWeave transformation

    class FakeAssessmentService implements IAssessmentService {
        Exception throwException;
        Object returnValue;
        public FakeAssessmentService(Object returnValue) {
            this.returnValue = returnValue;
        }
        public FakeAssessmentService(Exception throwException) {
            this.throwException = throwException;
        }
        public Object getResponse(Id assessmentId) {
            calledId = assessmentId;
            if(throwException != null) {
                throw throwException;
            }
            return returnValue;
        }
    }

    class FakeTransformer implements IDataTransformer {
        public AssessmentResponseTransformer.Input inputReceived;
        public Object transform(Object input) {
            this.inputReceived = (AssessmentResponseTransformer.Input)input;
            return true;
        }
    }
}