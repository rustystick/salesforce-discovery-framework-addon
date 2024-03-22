import { LightningElement, api, wire, track} from 'lwc';
import getResponse from '@salesforce/apex/Assessmentx.getAssessmentResponse';

export default class AssessmentResponse extends LightningElement {
    @track data;
    @track steps = [];
    @api recordId;

    @wire(getResponse, {assessmentId: "$recordId"})
    handleResponse({error, data}) {
        if(error) {
            console.error(error);
        }
        if(data) {
            this.data = data;
            this.steps = Object.entries(this.data).map(([key, val])=>{return {...val, key}});
        }
    }

    get hasData() {
        return !!this.data;
    }
}