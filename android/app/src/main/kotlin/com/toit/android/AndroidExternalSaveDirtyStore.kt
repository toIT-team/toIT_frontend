package com.toit.android

import android.content.Context

class AndroidExternalSaveDirtyStore(private val context: Context) {
  private companion object {
    const val DIRTY_PREFS = "external_save_dirty"
    const val DIRTY_FOLDER_IDS = "dirty_folder_ids"
  }

  fun markFolderDirty(folderId: Int) {
    val prefs = context.getSharedPreferences(DIRTY_PREFS, Context.MODE_PRIVATE)
    val current = prefs.getStringSet(DIRTY_FOLDER_IDS, emptySet()) ?: emptySet()
    val updated = current.toMutableSet()
    updated.add(folderId.toString())
    prefs.edit().putStringSet(DIRTY_FOLDER_IDS, updated).apply()
  }

  fun consumeDirtyFolderIds(): List<Int> {
    val prefs = context.getSharedPreferences(DIRTY_PREFS, Context.MODE_PRIVATE)
    val current = prefs.getStringSet(DIRTY_FOLDER_IDS, emptySet()) ?: emptySet()
    prefs.edit().remove(DIRTY_FOLDER_IDS).apply()
    return current.mapNotNull { it.toIntOrNull() }.filter { it > 0 }.distinct()
  }
}
