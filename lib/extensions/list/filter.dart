//we need to filter the results of all notes
//Stream<T> has a where() function but we want filter on Stream<List<T>>

//filter all the notes based on current user
//input is the list of streams output is the list of streams which pass the perticular test
extension Filter<T> on Stream<List<T>> {
  Stream<List<T>> filter(bool Function(T) where) =>
      map((items) => items.where(where).toList());
}