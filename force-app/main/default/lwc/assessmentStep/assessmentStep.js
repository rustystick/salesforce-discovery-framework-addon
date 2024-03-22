import { LightningElement, api, track } from 'lwc';

// replace with label
const Label = {
    "showSection" : "Show Section",
    "hideSection" : "Hide Section"
}
export default class AssessmentStep extends LightningElement {
    @api label = 'Dummy Title';
    @api key = 'dummyKey';

    @api 
    set stepData(data) {
        if(data) {
            this._stepData = data;
            // if everything under a step is NA then the entire step is NA
            this._isOpen = !Object.entries(data).reduce((acc, [_, curr])=> acc && (curr?.isNa ?? false), true);
        }
    }
    get stepData() {
        return this._stepData;
    }

    get hasStepData() {
        return !!this._stepData;
    }

    _isOpen = true;
    @api 
    get isOpen() {
        return this._isOpen;
    }
    set isOpen(val) {
        this._isOpen = val;
    }


    get divClass() {
        let classNames = 'slds-section slds-p-bottom_medium';
        classNames = this.isOpen ? classNames + ' slds-is-open' : classNames;
        return classNames;
    }

    get buttonLabel() {
        return this.isOpen ? Label.hideSection : Label.showSection;
    }
    
    toggleExpand() {
        this.isOpen = !this.isOpen;
    }
}