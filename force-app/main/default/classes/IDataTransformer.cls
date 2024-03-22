public interface IDataTransformer {
    /**
     * @description transform data from 1 shape to another
     * @param  input input obj
     * @return       return obj
     */
    Object transform(Object input);
}