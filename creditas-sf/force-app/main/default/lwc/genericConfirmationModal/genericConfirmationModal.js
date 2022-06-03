import { LightningElement, api } from 'lwc';

export default class GenericConfirmationModal extends LightningElement {
  _headerTitle = 'Confirmation';
  _yesLabel = 'Yes';
  _noLabel = 'No';

  @api
  get headerTitle() {
    return this._headerTitle;
  }

  set headerTitle(newValue) {
    this._headerTitle = newValue;
  }

  @api
  get yesLabel() {
    return this._yesLabel;
  }

  set yesLabel(newValue) {
    this._yesLabel = newValue;
  }

  @api
  get noLabel() {
    return this._noLabel;
  }

  set noLabel(newValue) {
    this._noLabel = newValue;
  }

  handleClose() {
    this.return('close');
  }

  handleYes() {
    this.return('yes');
  }

  handleNo() {
    this.return('no');
  }

  return(type) {
    this.dispatchEvent(new CustomEvent('modalreturn', { detail: type }));
  }
}