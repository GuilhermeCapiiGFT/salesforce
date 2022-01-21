import { LightningElement, track, api } from 'lwc';
import searchUser from '@salesforce/apex/GroupMembersLWC.searchUser';
import createMemberGroup from '@salesforce/apex/GroupMembersLWC.createMemberGroup';

export default class NewGroupMemberLWC extends LightningElement {
    @track roleValue = 'Member';
    @track userList = [];
    @track searchValue = '';
    @track searchId = '';
    @track mapUser = [];
    @track isModalOpen = true;
    @api groupname;
    @api groupid;
  
    get roleOptions() {
        return [
            { label: 'Admin', value: 'Admin' },
            { label: 'Standard', value: 'Standard' },        
        ];
    }

    roleChange(event) {
        this.roleValue = event.detail.value;
    }

    @track selectedRecordId;


    handleValueSelected(event) {
        this.selectedRecordId = event.detail;
    }

    onchangeSearch(event){
        console.log(event.detail.value);
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';

        searchUser({searchKey : event.detail.value})
            .then(result => {
              console.log(JSON.stringify(result));
              this.userList = result;
              this.userList.forEach(user => {

                this.mapUser.push( { key:user.id, value:user.Name } );

            });
            })
            .catch(error => {
                this.error = error;
            });
    }
    
    signControlUserList(event)
    { 
        if ( this.userList.length > 0 )
        {
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open';
        }
        else
        {
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        }
    }

    onclickSelecionarUser(event){
        //this.searchValue = this.mapUser.find(item => item.key === event.currentTarget.dataset.id ).value;
        this.searchValue = event.currentTarget.dataset.name;
        this.searchId = event.currentTarget.dataset.id;
        this.txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';

    }
    
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        const closeModal = new CustomEvent('close');
        this.dispatchEvent(closeModal);
    }

    saveModal(){
        console.log('groupname: ' + this.groupname);
        console.log('username: ' + this.searchValue);
        console.log('user: ' + this.searchId);
        console.log('role: ' + this.roleValue);
        console.log('groupid: ' + this.groupid);

        createMemberGroup({idGroup : this.groupid, idUser : this.searchId, role : this.roleValue})
        .then(result => {
            console.log('membro inserido');
            this.closeModal();
           
        })
        .catch(error => {
            this.error = error;
        });

    }

    getNameGroup(){
        const wiredGroup = new CustomEvent('nameGroup');
        this.dispatchEvent(wiredGroup)
    }

}