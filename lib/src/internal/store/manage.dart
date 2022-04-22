import 'dart:io';

import 'package:path/path.dart' as p;

import '../../misc/validate.dart';
import 'access.dart';
import 'directory.dart';

/// Manages a [StoreDirectory]'s representation on the filesystem, such as creation and deletion
class StoreManagement {
  /// The store directory to manage
  final StoreDirectory _storeDirectory;

  /// Manages a [StoreDirectory]'s representation on the filesystem, such as creation and deletion
  StoreManagement(this._storeDirectory)
      : _access = StoreAccess(_storeDirectory);

  /// Shorthand for [StoreDirectory.access], used commonly throughout
  final StoreAccess _access;

  /// Create all of the directories synchronously
  void create() {
    _access.real.createSync();
    _access.tiles.createSync();
    _access.stats.createSync();
    _access.metadata.createSync();
  }

  /// Create all of the directories asynchronously
  Future<void> createAsync() async {
    final List<Future<Directory>> jobs = [
      _access.real.create(),
      _access.tiles.create(),
      _access.stats.create(),
      _access.metadata.create(),
    ];
    await Future.wait(jobs);
  }

  /// Delete all of the directories synchronously
  ///
  /// This will remove all traces of this store from the user's device. Use with caution!
  void delete() => _access.real.deleteSync(recursive: true);

  /// Delete all of the directories asynchronously
  ///
  /// This will remove all traces of this store from the user's device. Use with caution!
  Future<void> deleteAsync() => _access.real.delete(recursive: true);

  /// Empty/reset all of the directories synchronously
  ///
  /// This internally calls [delete] then [create] to achieve the same effect.
  void reset() {
    delete();
    create();
  }

  /// Empty/reset all of the directories asynchronously
  ///
  /// This internally calls [deleteAsync] then [createAsync] to achieve the same effect.
  Future<void> resetAsync() async {
    await deleteAsync();
    await createAsync();
  }

  /// Rename the store directory synchronously
  ///
  /// The old [StoreDirectory] will still retain it's link to the old store, so always use the new returned value instead: returns a new [StoreDirectory] after a successful renaming operation.
  StoreDirectory rename(String storeName) {
    final String safe =
        safeFilesystemString(inputString: storeName, throwIfInvalid: true);

    _access.real.renameSync(
        p.joinAll([_storeDirectory.rootDirectory.access.real.path, safe]));

    return _storeDirectory.copyWith(storeName: safe);
  }

  /// Rename the store directory asynchronously
  ///
  /// The old [StoreDirectory] will still retain it's link to the old store, so always use the new returned value instead: returns a new [StoreDirectory] after a successful renaming operation.
  Future<StoreDirectory> renameAsync(String storeName) async {
    final String safe =
        safeFilesystemString(inputString: storeName, throwIfInvalid: true);

    await _access.real.rename(
        p.joinAll([_storeDirectory.rootDirectory.access.real.path, safe]));

    return _storeDirectory.copyWith(storeName: safe);
  }
}