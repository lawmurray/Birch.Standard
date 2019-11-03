READ:Integer <- 1;
WRITE:Integer <- 2;
APPEND:Integer <- 3;

/**
 * Create a directory.
 *
 * - path: Path of the directory, or path of a file in the directory.
 */
function mkdir(path:String) {
  cpp{{
  std::filesystem::path p = path;
  if (!std::filesystem::is_directory(p)) {
    p = p.parent_path();
  }
  std::filesystem::create_directories(p);
  }}
}

/**
 * Open a file for reading.
 *
 * - path : Path of the file.
 *
 * Return: File handle.
 *
 * If `path` includes non-existing directory, that directory is created (if
 * possible). The file is locked for reading (if possible).
 */
function fopen(path:String) -> File {
  return fopen(path, READ);
}

/**
 * Open a file.
 *
 * - path : Path of the file.
 * - mode : The mode, either `READ`, `WRITE`, or `APPEND`.
 *
 * Return: File handle.
 *
 * If `path` includes non-existing directory, that directory is created (if
 * possible). The file is locked for reading or writing as appropriate (if
 * possible).
 */
function fopen(path:String, mode:Integer) -> File {
  assert mode == READ || mode == WRITE || mode == APPEND;
  s:String;
  if mode == READ {
    s <- "r";
  } else if mode == WRITE {
    s <- "w";
    cpp{{
    std::filesystem::path p = path;
    if (!p.parent_path().empty()) {
      std::filesystem::create_directories(p.parent_path());
    }
    }}
  } else if (mode == APPEND) {
    s <- "a";
  }
  cpp{{
  auto f = ::fopen(path.c_str(), s.c_str());
  if (!f) {
    bi::error("could not open file " + path + ".");
  }
  lockf(fileno(f), F_LOCK, 0);
  return f;
  }}
}

/**
 * Flush a file.
 */
function fflush(file:File) {
  cpp{{
  ::fflush(file);
  }}
}

/**
 * Close a file.
 */
function fclose(file:File) {
  cpp{{
  ::fclose(file);
  }}
}

/**
 * File extension of a path.
 */
function extension(path:String) -> String {
  ext:String;
  cpp{{
  std::filesystem::path f(path);
  ext = f.extension().string();
  }}
  return ext;
}
