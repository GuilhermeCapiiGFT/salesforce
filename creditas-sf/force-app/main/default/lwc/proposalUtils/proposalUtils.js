function checksOnlyOne(event) {
  let currentCheckbox = event.currentTarget.name
  let currentCheckboxValue = event.currentTarget.value
  let modal = {}

  this.template.querySelectorAll('input[name='+currentCheckbox+']').forEach(elem => {
    let oldValue = elem.getAttribute('data-value')
    let newValue = currentCheckboxValue

    

    if(oldValue !== null && elem.value === oldValue) {
      elem.checked = false
      newValue = ''
      
    } else if(elem.value === currentCheckboxValue) {
      newValue = currentCheckboxValue
      elem.checked = true
    }
    elem.setAttribute('data-value', newValue)

    console.log({ oldValue })
    console.log({newValue})

    if (event.target.checked && (currentCheckboxValue == 'Rejeitar' || currentCheckboxValue == 'Pendenciar'))
    {
      let modalReason = (currentCheckboxValue == 'Rejeitar') ? 'reject' : 'pendency';
      let openModalReason = true;
      let modalReasonField = currentCheckbox;

      modal['modalReason'] = modalReason
      modal['openModalReason'] = openModalReason
      modal['modalReasonField'] = modalReasonField

      modal['fieldReason'] = elem.getAttribute('data-reason')
      modal['objectReason'] = 'PersonalDataSection__c'
    }
  })


  let info = getPercentage()
  info = {...info, modal}

  //this.sendInfo(info)

  return info
}

function getPercentage() {
  let returnedId = this.template.querySelector("div[data-id='ContainerDadosPessoais']").getAttribute("data-id")
  let topContainer = this.template.querySelector('div[data-id="' + returnedId + '"]')
  
  //let allCheckboxes = (topContainer.querySelectorAll('input[type="checkbox"]').length) / 3
  let selectedCheckboxes = topContainer.querySelectorAll('input[type="checkbox"]:checked')
  let totalLines = 9

  let isPending = false
  let isRejected = false

  let infoVariant = ''
  let infoValue = ''

  let info = {}
  
  let countSelectedCheckbox = 0

  selectedCheckboxes.forEach(element => {
    countSelectedCheckbox++

    if (element.value === 'Aprovar')         infoVariant = 'base-autocomplete'
    else if (element.value === 'Pendenciar') isPending = true
    else if (element.value === 'Rejeitar')   isRejected = true
  })
  
  if (isPending && !isRejected) infoVariant = 'warning'
  if (isRejected) infoVariant = 'expired'
  
  infoValue = (countSelectedCheckbox / totalLines) * 100
  selectedCheckboxes = 0
  
  info.variant = infoVariant
  info.value = infoValue
  info.returnedId = returnedId

  return info
}

export {checksOnlyOne}