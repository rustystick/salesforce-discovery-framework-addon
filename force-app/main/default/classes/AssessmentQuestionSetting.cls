public virtual class AssessmentQuestionSetting {
    public static final String PURPOSE_NA_CRITERIA = 'NA Criteria';

    private static AssessmentQuestionSetting setting;

    @TestVisible
    private Map<String, List<Assessment_Question_Setting__mdt>> settingsCache;

    private AssessmentQuestionSetting() {
        this.settingsCache = new Map<String, List<Assessment_Question_Setting__mdt>>();
    }

    public static AssessmentQuestionSetting getInstance() {
        if(setting == null) {
            setting = new AssessmentQuestionSetting();
        } 

        return setting;
    }

    /**
     * @description getNaValuesSettings description
     * @return   Map<DrivenQuestion, Map<DrivingQuestion, CriteriaValue>>
     */ 
    public Map<String, Map<String, String>> getNaValuesSettings() {
        if(!settingsCache.containsKey(PURPOSE_NA_CRITERIA)) {
           settingsCache.put(PURPOSE_NA_CRITERIA, [SELECT Driving_Question_Name__c, Driven_Question_Name__c, Criteria_Value__c FROM Assessment_Question_Setting__mdt WHERE Purpose__c = :PURPOSE_NA_CRITERIA]);
        }
        List<Assessment_Question_Setting__mdt> settings = settingsCache.get(PURPOSE_NA_CRITERIA);
        
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        for(Assessment_Question_Setting__mdt setting : settings) {
            if(!result.containsKey(setting.Driven_Question_Name__c)) {
                result.put(setting.Driven_Question_Name__c, new Map<String, String>());
            }
            result.get(setting.Driven_Question_Name__c).put(setting.Driving_Question_Name__c, setting.Criteria_Value__c);
        }

        return result;
    }


}