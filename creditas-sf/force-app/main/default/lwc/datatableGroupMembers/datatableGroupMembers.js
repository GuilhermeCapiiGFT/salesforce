import { LightningElement, wire, api, track} from 'lwc';
import searchGroupMember from '@salesforce/apex/GroupMembersLWC.searchGroupMember';
import deleteMembers from '@salesforce/apex/GroupMembersLWC.deleteMembers';
import { NavigationMixin } from 'lightning/navigation';
import getNameGroup from '@salesforce/apex/GroupMembersLWC.getNameGroup';
import updateMemberGroup from '@salesforce/apex/GroupMembersLWC.updateMemberGroup';
import { CurrentPageReference } from 'lightning/navigation';

// row actions
const actions = [
    { label: 'Edit', name: 'edit'}, 
    { label: 'Delete', name: 'delete'}
];
 
// datatable columns with row actions
const columns = [
    { label: 'Membro', fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'name'}, target: '_blank' }, sortable: true },
    { label: 'Title', fieldName: 'title', wrapText: 'true'},
    { label: 'Status', fieldName: 'status', wrapText: 'true'},
    { label: 'Group Member Role', fieldName: 'role', wrapText: 'true'},
    {
        type: 'action',
        typeAttributes: {
            rowActions: actions,
            menuAlignment: 'auto',                        
        }
    }    
];

export default class BasicDatatable extends NavigationMixin(LightningElement) {
    @track recordId = '';
    @api memberId = '';

    data = [];
    columns = columns; 
    record = {};
    draftValues = []; 

    currentPageReference = null;
        
    @track exibirModalMember = false;

    @track bShowModal = false;
    @track currentRecordId;
    @track isEditForm = false;
    @track role = '';
    @track userName = '';
    @track status = '';
    @track title = '';
    @track groupMemberId = '';

    get roleOptions() {
        return [
            { label: 'Admin', value: 'Admin' },
            { label: 'Standard', value: 'Standard' },        
        ];
    }

    get statusOptions() {
        return [
            { label: 'Ativo', value: 'Ativo' },
            { label: 'Inativo', value: 'Inativo' },        
        ];
    } 
    
    connectedCallback(){
        this.getNameGroup();
        this.searchGroupMember();
    }

    @wire( CurrentPageReference )
    getURLParameters( currentPageReference )
    {
        if( currentPageReference )
        {
            if( currentPageReference.state.c__recordId)
            {
                this.recordId = currentPageReference.state.c__recordId;
                console.log(this.recordId);               
            }
        }
    }

    searchGroupMember(){   
        searchGroupMember( { idGroup: this.recordId  })
        .then( result => 
        {                               
            this.data = result;
            console.log(this.data);            
        })
        .catch( error =>
        {
            console.log('error: ' + error);
        });
    }   
    getNameGroup(){   
        getNameGroup( { idGroup: this.recordId })
        .then( result => 
        {
            console.log(result);            
            this.nameGroup = result;
        })
        .catch( error =>
        {
            console.log('error: ' + error);
        });
    }     

    clickNewGroup(){
        this.exibirModalMember = true;
        console.log(this.nameGroup);
    }
   
    closeModal(){
        this.exibirModalMember = false;
        window.location.reload();        
    }   

    handleRowActions(event) {
        let actionName = event.detail.action.name;
        console.log('actionName ====> ' + actionName);
        let row = event.detail.row;
        console.log('row ====> ' + JSON.stringify(row));        
        switch (actionName) {            
            case 'edit':
                this.editCurrentRecord(row);
                break;
           case 'delete':
                this.deleteCons(row);
                break;
        }
    }

    editCurrentRecord(currentRow) {
        // open modal box
        this.bShowModal = true;
        this.isEditForm = true;
        // assign record id to the record edit form       
        this.title = currentRow.title;
        this.userName = currentRow.name;
        this.role = currentRow.role;
        this.status = currentRow.status;
        this.groupMemberId = currentRow.memberGroupId;
    }

    deleteCons(currentRow){
        deleteMembers({memberId: currentRow.memberGroupId})
            .then(result => {
              console.log(JSON.stringify(result));
              if(result == 'success'){                 
                  window.location.reload();
              }              
            })
            .catch(error => {
                this.error = error;
            });
    }

    onChangeTitle(event){
        this.title = event.detail.value;
        console.log(this.title);
    }

    onChangeStatus(event){
        this.status = event.detail.value;
        console.log(this.status);
    }

    onChangeRole(event){
        this.role = event.detail.value;
        console.log(this.role);
    }

    updateModal(){
        updateMemberGroup({idMemberGroup: this.groupMemberId, title: this.title, status: this.status, role: this.role})
            .then(result => {
              console.log(JSON.stringify(result));
              if(result == 'success'){
                  this.bShowModal = false;
                  this.isEditForm = false;
                  window.location.reload();
              }              
            })
            .catch(error => {
                this.error = error;
            });
    }        
}