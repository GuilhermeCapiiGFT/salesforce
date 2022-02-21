import { LightningElement, api } from 'lwc';

const IMG_SIZE = 400;
const IMG_MODIFY_SIZE = 80;

export default class ModalImage extends LightningElement {

    rotate = 0;
    zoom = 400;  
    imgLoaded = false;

    @api sourceImg;

    reset(){
        this.zoom = IMG_SIZE;
        this.rotate = 0;
    }

    handlerLoadImage(){
        this.imgLoaded = true;
        document.body.style.overflow = 'hidden';
        this.template.querySelector('.container-img').addEventListener('click', this.handleClose);
    }
  
    handleDecreaseImg(){ 
        let decreaseImg = ((this.zoom - IMG_MODIFY_SIZE) < IMG_SIZE )? IMG_SIZE : this.zoom - IMG_MODIFY_SIZE;
        let documentImg = this.template.querySelector('img'); 
        documentImg.style.height = decreaseImg +'px'; 
        documentImg.style.width = decreaseImg  +'px'; 
        this.zoom = decreaseImg;
    }

    handleIncreaseImg(){
        let screenHeight = window.innerHeight;
        let screenWidth = window.innerWidth;
        let currentZoom = this.zoom;
        let increaseImg = currentZoom + IMG_MODIFY_SIZE;
        if( !(increaseImg >= screenHeight || increaseImg >= screenWidth) ){
            let documentImg = this.template.querySelector('img'); 
            documentImg.style.height = increaseImg  +'px'; 
            documentImg.style.width = increaseImg  +'px'; 
            this.zoom = increaseImg;
        }
    }
  
    handleRotate(){ 
        let oldRotate = this.rotate;
        let newRotate = oldRotate + 90;
        let documentImg = this.template.querySelector('img'); 
        documentImg.style.transform = 'rotate('+newRotate+'deg)';
        this.rotate = newRotate;
    }

    handlerWheel(e){
        if(e.deltaY < 0){
            this.handleIncreaseImg();
        }else{
            this.handleDecreaseImg();
        }
    }

    handleClose(){
        // this.reset();
        document.body.style.overflow = 'visible';
        const selectedEvent = new CustomEvent('closemodal', {
            bubbles    : true,
            composed   : true,
            cancelable : true,
            detail: {}
        });
        this.dispatchEvent(selectedEvent);
    }
}