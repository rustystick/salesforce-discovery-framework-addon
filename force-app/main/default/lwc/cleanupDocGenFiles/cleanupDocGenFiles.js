import { LightningElement, api } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import markFileForDeletionAndScheduleBatch from "@salesforce/apex/DocGenCleanup.markFileForDeletionAndScheduleBatch";

export default class CleanupDocGenFiles extends OmniscriptBaseMixin(LightningElement) {
    @api debug = false;
    @api cleanUpInMinutes = 5;
    @api batchSize = 100;

    @api
    set done(pdfGenContentVersionId) {
        if (pdfGenContentVersionId) {
            const { docGenContentVersionId } = this.omniJsonData;
            markFileForDeletionAndScheduleBatch({
                contentVersionIds: [pdfGenContentVersionId, docGenContentVersionId],
                delayInMinutes: this.cleanUpInMinutes,
                batchSize: this.batchSize
            }).then(() => {
                if(this.debug) {
                    console.log(`marking files ${pdfGenContentVersionId} and ${docGenContentVersionId} for delete and starting cleanup batch`)
                }
            }).catch(error => console.error(error));
        }
    }
    get done() {
        return this._done;
    }
    
}