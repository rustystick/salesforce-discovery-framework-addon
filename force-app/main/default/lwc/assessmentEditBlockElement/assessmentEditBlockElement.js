import { LightningElement, api, track } from 'lwc';

export default class AssessmentEditBlockElement extends LightningElement {
    @track selectedRowNumber;
    @api 
    set editBlockData(value) {
        this._data = value;
    };
    get editBlockData() {
        return this._data;
    }

    get label() {
        return this.editBlockData.label;
    }

    get values() {
        // for some reason in OS, it doesn't become an array until it has more than 1 entry
        return (Array.isArray(this.editBlockData.value) ? this.editBlockData.value : [this.editBlockData.value])
                    .map((item, rowNum)=>{return {...item, rowNum: rowNum}});
    }

    get columns() {
        //TODO: to be updated to allow configuration
        return this.getColumns(4);
    }

    get tableData() {
        // if every entry is falsy, skip the row
        return this.values.filter(entry => !Object.entries(entry).every(([_, val]) => !val.value)).map((entry) => {
            return Object.entries(entry).reduce((acc, [key, val]) => {
                if(val.value) {
                    acc[key] = val.value;
                }
                return acc;
            }, {rowNum: entry.rowNum});
        })
    }

    get selectedEntry() {
        if(this.selectedRowNumber === undefined) {
            return {};
        }
        for(const value of this.values) {
            if(value.rowNum === this.selectedRowNumber) {
                const {rowNum, ...rest} = value;
                return rest;
            }
        }
    }

    get hasValues() {
        return this.values && this.values?.length > 0;
    }

    /**
     * @typedef {Object} Column
     * @property {string} fieldName
     * @property {string} label
     * @property {Object} typeAttributes
     * @property {"text" | "phone" | "email" | "url" | "button" | null} type
     */
    
    /**
     * get column spec for the data table
     * @param {number} maxNumOfColumns max number of fields to display
     */
    getColumns(maxNumOfColumns) {
        const objectEntries = Object.entries(this.values[0]);
        const columnLength = Math.min(maxNumOfColumns, objectEntries.length);

        /**
         * @type {Column[]}
         */
        const columns = [{type: 'button', typeAttributes : {label: 'View', variant: 'base'}, initialWidth: 60}];

        for(let i = 0; i < columnLength; i++) {
            const [key, val] = objectEntries[i];
            if(key === 'key' || !val.label) {
                continue;
            }
            //TODO: translate AssessmentQuestion type -> lightning-data-table type
            columns.push({
                fieldName: key,
                label: val.label
            });
        }
        return columns;
    }


    renderedCallback() {
        this.modal = this.template.querySelector('dialog');
    }  

    handleView(event) {
        this.selectedRowNumber = event.detail.row.rowNum;
        this.openModal();
    }

    openModal(_) {
        this.modal.showModal();
    }

    closeModal(_) {
        this.selectedRowNumber = undefined;
        this.modal.close();
    }
}