/**
 * @author Otávio Frank
 */
public class MinuatorHelper {
    
    private MinuatorVO.Persons findActivePersonTab(MinuatorVO minuator) {

        for ( MinuatorVO.Persons person : minuator.persons ) {

            if ( person.showSection ) return person;
        }

        return null;
    }
}