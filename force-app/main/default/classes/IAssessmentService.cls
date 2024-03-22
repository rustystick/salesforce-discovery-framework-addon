public interface IAssessmentService {
    /**
     * @description get the response summary of an assessment
     * @param  assessmentId assessmentId
     * @return              response of a completed assessment
     */
    Object getResponse(Id assessmentId);
}