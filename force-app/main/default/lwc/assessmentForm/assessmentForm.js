import { LightningElement, api, track } from 'lwc';

const HAS_LOOKUP_IN_TYPE_AHEAD = 'Lookup';

export default class AssessmentForm extends LightningElement {
    @track dataArray = [];

    @api
    set formData(data) {
        if(data) {
            this.dataArray = Object.entries(data).map(([key, val])=>{return {...val, key}}).filter(field => 
                !field.key.toLowerCase().includes(HAS_LOOKUP_IN_TYPE_AHEAD.toLowerCase())
            );
        }
    }
    get formData() {
        return this.dataArray;
    }
}