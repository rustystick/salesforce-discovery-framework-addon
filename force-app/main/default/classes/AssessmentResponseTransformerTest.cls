@IsTest
public class AssessmentResponseTransformerTest {

    @IsTest
    static void transformShouldReturnGeneratedDateTime(){
        AssessmentResponseTransformer transformer = new AssessmentResponseTransformer();

        Map<String, Object> result = (Map<String, Object>)transformer.transform(new AssessmentResponseTransformer.Input('en', new Map<String, String>{}));
        
        Assert.isTrue(result.containsKey('generatedDateTime'), 'result should contain the generated date time');
        Assert.isInstanceOfType(result.get('generatedDateTime'), String.class, 'generatedDateTime should be string');
    }

    @IsTest
    static void transformShouldTurnEntriesIntoArrays(){
        AssessmentResponseTransformer transformer = new AssessmentResponseTransformer();

        Step step1 = new Step();
        Field field1 = new Field();
        field1.value = 'test';
        field1.dataType = 'Text';
        step1.value.put('field1', field1);

        Map<String, Object> payload = new Map<String, Object>{'step1' => step1, 'step2' => new Step()};

        Map<String, Object> result = (Map<String, Object>)transformer.transform(new AssessmentResponseTransformer.Input('en', payload));

        Assert.isTrue(result.containsKey('steps'), 'result should contain steps attribute in response');
        Assert.isInstanceOfType(result.get('steps'), List<Object>.class, 'steps should be array type');
        Assert.areEqual(payload.keySet().size(), ((List<Object>)result.get('steps')).size(), 'size of steps should equal to the size of steps passed in');
        Map<String, Object> responseStep1 = (Map<String, Object>)((List<Object>)result.get('steps'))[0];
        Assert.areEqual('step1', responseStep1.get('stepName'), 'the step name should be in the step object as step name');
    }


    @IsTest
    static void transformShouldHandleEditBlock(){
        AssessmentResponseTransformer transformer = new AssessmentResponseTransformer();

        EditBlock editBlock1 = new EditBlock();
        Step step1 = new Step();
        step1.value.put('editBlock1', editBlock1);

        Field field1 = new Field();
        field1.value = 'test';
        field1.dataType = 'Text';
        editBlock1.value.add(new Map<String, Field>{'field1' => field1});


        Map<String, Object> payload = new Map<String, Object>{'step1' => step1, 'step2' => new Step()};

        Map<String, Object> result = (Map<String, Object>)transformer.transform(new AssessmentResponseTransformer.Input('en', payload));
        
        Assert.isInstanceOfType(result.get('steps'), List<Object>.class, 'steps should be array type');
        Map<String, Object> responseStep1 = (Map<String, Object>)((List<Object>)result.get('steps'))[0];
        Assert.isInstanceOfType(responseStep1.get('value'), List<Object>.class, 'step values should be an array');
        Map<String, Object> editBlock = (Map<String, Object>)((List<Object>)responseStep1.get('value'))[0];
        Assert.isInstanceOfType(editBlock.get('value'), List<Object>.class, 'edit block value should be an array');
        Map<String, Object> editBlockEntry1 = (Map<String, Object>)((List<Object>)editBlock.get('value'))[0];
        Assert.isTrue(editBlockEntry1.containsKey('rows'), 'edit block entries should have rows property');
        
    }

    //TODO: more rigid tests can be done...

    abstract class Element {
        String label;
    }

    class Step extends Element {
        Map<String, InputElement> value = new Map<String, InputElement>();
    }

    abstract class InputElement extends Element{}

    class Field extends InputElement {
        String value;
        String dataType;
        Boolean isNa;
    }

    public class EditBlock extends InputElement {
        String dataType = 'EditBlock';
        List<Map<String, Field>> value = new List<map<String, Field>>();
    }
}