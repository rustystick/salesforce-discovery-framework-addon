public interface IAssessmentResponseService {
    /**
     * @description saveResponse
     * @param  omniInput  input map from vlocity open interface
     * @param  omniOption option map from vlocity open interface
     * @return            assessmentId saved
     */ 
    Id saveResponse(Map<String, Object> omniInput, Map<String, ObjecT> omniOption);

    /**
     * @description saveResponse
     * @param  assessmentId previously saved assessment Id for amendment or coninuation
     * @param  omniInput    input map from vlocity open interface
     * @param  omniOption   option map from vlocity open interface
     * @return              assessmentId saved
     */ 
    Id saveResponse(Id assessmentId, Map<String, Object> omniInput, Map<String, ObjecT> omniOption);
}