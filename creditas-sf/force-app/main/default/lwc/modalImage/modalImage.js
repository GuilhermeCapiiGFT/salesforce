import { LightningElement, api } from 'lwc';

const IMG_SIZE = 400;
const IMG_MODIFY_SIZE = 50;

export default class ModalImage extends LightningElement {

    rotate = 0;
    zoom = 400;
    imgClass = 'height: 400px; position: relative; width: 400px;transform: none;';
  
    imgLoaded = false;

    @api sourceImg;
    
    // @api isModalOpen = false;
    // drag = false;
    // renderedCallback(){
    //     this.template.querySelector('.slds-backdrop').addEventListener('click', this.handleClose);
    //     this.template.querySelector('img').addEventListener('mousemove', function(e){
    //         console.log(e);
    //     });
    //     this.template.querySelector('img').addEventListener('mousedown', () => this.drag = false);
    //     this.template.querySelector('img').addEventListener('mousemove', () => this.drag = true);
    //     this.template.querySelector('img').addEventListener('mouseup', () => console.log( this.drag ? 'drag' : 'click'));
    // }
    reset(){
        this.zoom = IMG_SIZE;
        this.rotate = 0;
        this.imgClass = 'height: 400px; position: relative; width: 400px; transform: none;';
    }
    loadImage(){
        this.imgLoaded = true;
    }
  
    handleDecreaseImg(){ 
        let decreaseImg = ((this.zoom - IMG_MODIFY_SIZE) < IMG_SIZE )? IMG_SIZE : this.zoom - IMG_MODIFY_SIZE;
        let newImgClass = 'height:'+decreaseImg+'px; position: relative; width:'+decreaseImg+'px; transform: none;transform: rotate('+this.rotate+'deg);';
        this.imgClass = newImgClass;
        this.zoom = decreaseImg;
    }

    handleIncreaseImg(){
        let screenHeight = window.innerHeight;
        let screenWidth = window.innerWidth;
        let currentZoom = this.zoom;
        let increaseImg = currentZoom + IMG_MODIFY_SIZE;
        if( !(increaseImg >= screenHeight || increaseImg >= screenWidth) ){
            let newImgClass = 'height:'+increaseImg+'px; position: relative; width:'+increaseImg+'px; transform: none;transform: rotate('+this.rotate+'deg);';
            this.imgClass = newImgClass;
            this.zoom = increaseImg;
        }
    }
  
    handleRotate(){ 
        let oldRotate = this.rotate;
        let newRotate = oldRotate + 90;
        let newImgClass = 'height:'+this.zoom+'px; position: relative; width:'+this.zoom+'px; transform: none;transform: rotate('+newRotate+'deg);';
        this.imgClass = newImgClass;
        this.rotate = newRotate;
    }

    handleClose(){
        console.log('close');
        this.reset();
        const selectedEvent = new CustomEvent('closemodal', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {}
        });
        this.dispatchEvent(selectedEvent);
    }
}