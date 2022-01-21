function cpfMask(val){
    const x = val.replace(/\D+/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})(\d{0,2})/);
    return !x[2] ? x[1] : `${x[1]}.${x[2]}` + (x[3] ? `.${x[3]}` : ``) + ( x[4] ? `-${x[4]}` : ``);
};


function generalMask (value, mask) {
    var DIGIT = "0";
    var ALPHA = "A";
    var ALPHANUM = "S";
    var pattern = (typeof mask === 'object' ? mask.pattern : mask),
        patternChars = pattern.replace(/\W/g, ''),
        output = pattern.split(""),
        values = value.toString().replace(/\W/g, ""),
        charsValues = values.replace(/\W/g, ''),
        index = 0,
        i,
        outputLength = output.length
    ;

    for(i = 0; i < outputLength; i++) {
        if(index >= values.length) {
            if(patternChars.length == charsValues.length) {
                return output.join("");
            }
            else{
                break;
            }
        }
        else{
            if((output[i] === DIGIT && values[index].match(/[0-9]/)) ||
                (output[i] === ALPHA && values[index].match(/[a-zA-Z]/)) ||
                (output[i] === ALPHANUM && values[index].match(/[0-9a-zA-Z]/))) {

                output[i] = values[index++];
            } 
            else if(output[i] === DIGIT || output[i] === ALPHA || output[i] === ALPHANUM) {
                return output.slice(0, i).join("");
            }
            else if(output[i] === values[index]) {
                index++;
            }
        }
    }
    return output.join("").substr(0, i);
};

export { cpfMask, generalMask }