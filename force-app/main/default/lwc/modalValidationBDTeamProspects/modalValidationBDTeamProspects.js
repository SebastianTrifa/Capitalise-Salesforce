import { LightningElement, api } from 'lwc';

export default class ModalValidationBDTeamProspects extends LightningElement {
    @api visible;
    @api title;
    @api name;
    @api message;
    @api confirmLabel;
    @api cancelLabel;

    handleClick(event) {
        let finalEvent = {
            status: event.target.name
        };

        this.dispatchEvent(new CustomEvent('closemodalclick', {detail: finalEvent}));
    }
}