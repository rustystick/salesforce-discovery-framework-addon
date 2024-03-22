public with sharing class AssessmentResponseTransformer implements IDataTransformer {

    public Object transform(Object input) {
        DataWeave.Result result = new DataWeaveScriptResource.AssessmentResponseToPdfJson().execute(new Map<String, Object>{'payload' => JSON.serialize(input)}); 
        return JSON.deserializeUntyped(result.getValueAsString());
    }

    public class Input {
        public String locale;
        public DateTime generatedDateTime;
        public Object payload;

        public Input(String locale, Object payload) {
            this.locale = locale;
            this.payload = payload;
            this.generatedDateTime = DateTime.now();
        }
    }

}