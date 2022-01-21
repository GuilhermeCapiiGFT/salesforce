import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RelatedListGroupMember extends NavigationMixin(LightningElement) {
    @api recordId = '';

    navigateToTab() {
       // console.log(this.recordId);
        this[NavigationMixin.Navigate]({            
            type: 'standard__navItemPage',
            attributes: {
                //Name of any CustomTab. Visualforce tabs, web tabs, Lightning Pages, and Lightning Component tabs
                apiName: 'DataGroupMember'
            },
            state: {
               c__recordId: this.recordId
            }
        });
    }
}