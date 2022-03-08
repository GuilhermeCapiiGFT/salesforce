import { LightningElement, track} from 'lwc';

export default class MinuatorSearch extends LightningElement {
<<<<<<< HEAD
    @track showScreenNotFound = false;
    @track showScreenUnavailableEdit = false;
    @track showScreenError = false;
    @track showScreenDefault = true


    changeNotFound(){       
        this.showScreenNotFound = true;
        this.showScreenUnavailableEdit = false;
        this.showScreenDefault = false;
        this.showScreenError = false;
    }

    changeUnavailableEdit(){
        this.showScreenNotFound = false;
        this.showScreenUnavailableEdit = true;
        this.showScreenDefault = false;
        this.showScreenError = false;
    }

    changeError(){
        this.showScreenNotFound = false;
        this.showScreenUnavailableEdit = false;
        this.showScreenDefault = false;
        this.showScreenError = true;
    }

    handleClick(){
        this.showScreenNotFound = false;
        this.showScreenUnavailableEdit = false;
        this.showScreenDefault = true;
        this.showScreenError = false;
    }
=======
    
>>>>>>> develop
}