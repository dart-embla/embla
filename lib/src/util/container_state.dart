import '../../container.dart';

class ContainerState {
  IoCContainer _state;

  ContainerState(this._state);

  set state(IoCContainer state) {
    _state = _state.apply(state);
  }

  IoCContainer get state => _state;
}
