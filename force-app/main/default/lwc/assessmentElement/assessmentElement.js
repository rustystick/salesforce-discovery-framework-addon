import { LightningElement, api } from 'lwc';
import LANG from '@salesforce/i18n/lang';

const language = LANG.includes('en') ? 'en' : 'fr';

/**
 * 
 * @param {string} dateString string 
 * @returns {string} formatted date string 
 */
const formatDate = dateString => {
    const date = new Date(dateString);
    let year = Intl.DateTimeFormat(language, {year: 'numeric', timeZone: 'UTC'}).format(date).replace('.','').toUpperCase();
    let month = Intl.DateTimeFormat(language, {month: 'short', timeZone: 'UTC'}).format(date).replace('.','').toUpperCase();
    let day = Intl.DateTimeFormat(language, {day: '2-digit', timeZone: 'UTC'}).format(date).replace('.','').toUpperCase();
    return `${year}-${month}-${day}`;
}

/**
 * 
 * @param {string} timeString 
 * @returns {string} formatted time string
 */
const formatTime = timeString => {
    return Intl.DateTimeFormat(language, 
        { hour:"numeric", minute: "numeric", hour12: true, timeZone: "UTC"}).format(
            new Date(`2020-10-01T${timeString}`)
    );
}


export default class AssessmentElement extends LightningElement {
    @api set elementData(data) {
        this._elementData = data;
    };
    get elementData() {
        return this._elementData;
    }

    get isNa() {
        return this.elementData?.isNa;
    }

    get naLabel() {
        return 'NA';
    }

    get dataType() {
        const dataType = this.elementData?.dataType?.toLowerCase();

        return dataType;
    }

    get value() {
        if(!this.elementData.value) {
            return '';
        }
        switch(this.dataType) {
            case 'date':
                return formatDate(this.elementData?.value);
            case 'time':
                return formatTime(this.elementData?.value);
            case 'boolean':
                return this.elementData?.value === 'true';
            case 'checkbox':
                return this.elementData?.value === 'true';
            default:
                return this.elementData?.value;
        }
    }

    get label() {
        return this.elementData?.label;
    }
    get key() {
        return this.elementData?.key;
    }

    get isRichText() {
        return this.dataType === 'textblock';
    }
    get isTextArea() {
        return this.dataType === 'textarea';
    }
    get isEditBlock() {
        return this.dataType === 'editblock';
    }
    get isBoolean() {
        return this.dataType === 'boolean' || this.dataType === 'checkbox';
    }
    get isTelephone() {
        return this.dataType === 'telephone';
    }
    get isBlock() {
        return this.dataType === undefined && typeof this.value === 'object';
    }
}

export {formatDate, formatTime};