import { LightningElement, api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import viewContract from '@salesforce/apex/ProposalContractController.viewContract';
import uploadFile from '@salesforce/apex/ProposalContractController.uploadFile';

export default class TestVisualize extends NavigationMixin(LightningElement) {

  @api recordId;
  fileData;
  downloadUrl;
  openfileUpload(event) {
      const file = event.target.files[0]
      let reader = new FileReader()
      reader.onload = () => {
          let base64 = reader.result.split(',')[1]
          console.log(reader.result);
          this.fileData = {
              'filename': file.name,
              'base64': base64
          }
          console.log(this.fileData);
          //this.parseAndDownload(base64);
      }
      reader.readAsDataURL(file)
  }
  /*
   handleFileSelect(event) {
      // Get the list of uploaded files
      let file = event.detail.files[0];
      console.dir(file);
      let reader = new FileReader();

      reader.onloadend = ( () => {
        let fileContents = reader.result;
        console.log(fileContents);
        let base64Mark = 'base64,';
        let dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
        console.log(dataStart);
        fileContents = fileContents.substring(dataStart);
        console.log(fileContents);
        let base64Data = encodeURIComponent(fileContents);
        this.parseAndDownload(base64Data);
      })
  
      reader.readAsDataURL(file); // converts the blob to base64 and calls onload
    }

    parseAndDownload(base64Data){
      //let blob = new Blob([base64Data], { type: 'application/zip' });
      let link = document.createElement('a');
      link.download = 'hello2.zip';
      link.href = URL.createObjectURL(base64Data);
      link.click();

    }
    */
    handleClick(){
      const {base64, filename} = this.fileData
      uploadFile({ base64, filename }).then(result=>{
          this.fileData = null
          this.downloadUrl = result;
          this.handleNavigate();
      })
  }

  handleNavigate() {
    const config = {
        type: 'standard__webPage',
        attributes: {
            url: this.downloadUrl
        }
	};
    this[NavigationMixin.Navigate](config);
  }

    handleView(event) {
        viewContract({ loanApplicationId: 'LAP-B9BBE976-49B1-4992-8747-00518E59202C' })
        .then(result => {

          console.dir(result);
          //console.log(resultado.length);
          //console.log(typeof resultado);

          // this.downloadUrl = result;
          // this.handleNavigate();


          //console.dir(result);
          
          //let blob = new Blob([result]);
          
          // let encoded64 = encodeURIComponent(blob);

          let downloadLink = document.createElement("a");
          downloadLink.href = "data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,"+result;
          downloadLink.download = "filename.docx";
          downloadLink.click();

          // let reader = new FileReader();
          
          // reader.onloadend = function() {

          //   console.dir(reader.result); // data url
          //   // let link;
          //   // //link.download = 'ZeLeoTest.docx';
          //   // link.href = reader.result;
          //   // console.log(link.href);
          //   // link.click();
          // };

          // reader.readAsDataURL(blob); // converts the blob to base64 and calls onload
          
          // reader.onerror = function() {
          //   console.log(reader.error);
          // };
          

          // let link = document.createElement('a');
          // link.download = 'ZeLeoTest.docx';
          // link.href = URL.createObjectURL(result);

          // link.click();

         
          })
          .catch((error) => {
            console.log("callout error ===> " + error);
            console.dir(error);
          });
    }     
}