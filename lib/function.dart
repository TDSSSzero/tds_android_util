///无参数请求回调
typedef VoidCallback = dynamic Function();

///回调一个参数
typedef SingleCallback<D> = dynamic Function(D data);

///回到俩个参数
typedef TwiceCallback<O, T> = dynamic Function(O dataOne, T dataTwo);

///回调三个参数
typedef ThreeCallback<O, T, K> = dynamic Function(O dataOne, T dataTwo, K threeData);
