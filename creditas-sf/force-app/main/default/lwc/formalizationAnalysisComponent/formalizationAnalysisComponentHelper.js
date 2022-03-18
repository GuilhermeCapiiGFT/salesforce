export const helper = {
   
    formatDate() {
        let dt = new Date()
    
        const formatter = new Intl.DateTimeFormat('pt-BR', {
          year: 'numeric',
          month: 'numeric',
          day: 'numeric',
          hour: '2-digit',
          minute: '2-digit',
          hour12: false
        })
    
        let formattedDate = formatter.format(dt)
        
        return formattedDate
    },

    sortArray(array){
      if(array){
          return array.sort( (a,b) => {
              return a.id - b.id;
          });
      } else {
          return [];
      }
      
  },

  returnNewObject(id,objInput,dataInput,propertyName,inputSection,inputLabel){
    let label;
    if(inputLabel){
        label = inputLabel;
    } else {
        label = objInput[propertyName].label === 'Número do documento' ? dataInput.DocumentType__c : objInput[propertyName].label
    }
  
    let inputValue = dataInput ? dataInput[propertyName] : '';
    return {    id: id, 
                inputName: objInput[propertyName].apiName,
                inputType: objInput[propertyName].dataType,
                inputDisabled: !objInput[propertyName].updateable, 
                inputLabel: label, 
                inputValue: inputValue,
                inputSection: inputSection 
            };
  }

}