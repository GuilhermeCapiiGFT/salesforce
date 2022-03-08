export const helper = {

    showToast(title, message, variant){
        const event = new ShowToastEvent({
              title: title,
              message: message,
              variant: variant,
              mode: 'dismissable'
            });
            this.dispatchEvent(event);
    },
    
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
    }

}