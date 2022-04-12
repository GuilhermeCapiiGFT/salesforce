import { LightningElement } from 'lwc';

const quickLinks = [
    {label : 'Crivo',                  url: 'https://creditas-crivo.crivo.com.br/Login.aspx?ReturnUrl=%2Fresultado.aspx%3Flogs%3D2682204&logs=2682204'},
    {label : 'BrFlow',                 url: 'https://www.brflow.com.br/autenticacao/autenticacao/login'},
    {label : 'Receita Federal',        url: 'https://servicos.receita.fazenda.gov.br/Servicos/CPF/ConsultaSituacao/ConsultaPublica.asp'},
    {label : 'Checktudo',              url: 'https://www.checktudo.com.br/'},
    {label : 'Emailage',               url: 'https://app.emailage.com/query'},
    {label : 'Data Trust',             url: 'https://datatrust.clearsale.com.br/#/'},
    {label : 'DENATRAM',               url: 'https://portalservicos.senatran.serpro.gov.br/#/consultas/veiculo'},
    {label : 'Zapay',                  url: 'https://usezapay.com.br/creditas'},
    {label : 'Biometria - Visualizar', url: 'https://www.certiface.com.br:8443/certifacepainel/#/dashboard'},
    {label : 'Biometria - Enviar',     url: 'https://www.certiface.com.br/tokensms/certifacetoken/oiti'}
];

export default class ProposalQuickLinksComponent extends LightningElement {

    sectionQuickLinks = quickLinks;

}