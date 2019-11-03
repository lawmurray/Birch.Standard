/**
 * Abstract writer.
 *
 * Typical use is to use the `Writer` factory function to instantiate an
 * object of an appropriate derived class based on the file extension of the
 * given path:
 *
 *     auto writer <- Writer(path);
 *
 * A write of a single buffer can then be performed with:
 *
 *     writer.write(buffer);
 *
 * A write of a sequence of buffers can be performed with:
 *
 *     writer.startSequence();
 *     writer.write(buffer1);
 *     writer.write(buffer2);
 *     writer.write(buffer3);
 *     writer.endSequence();
 *
 * which is useful for not keeping the entire contents of the file, to be
 * written, in memory.
 *
 * Finally, close the file:
 *
 *     writer.close();
 *
 * A file may not be valid until the writer is closed, depending on the file
 * format.
 */
abstract class Writer {
  /**
   * Open a file.
   *
   * - path : Path of the file.
   */
  abstract function open(path:String);
  
  /**
   * Write the entire contents of the file.
   *
   * - buffer: Buffer to write.
   */
  abstract function write(buffer:MemoryBuffer);
  
  /**
   * Flush accumulated writes to the file.
   */
  abstract function flush();
  
  /**
   * Close the file.
   */
  abstract function close();

  /**
   * Start a mapping.
   */
  abstract function startMapping();
  
  /**
   * End a mapping.
   */
  abstract function endMapping();
  
  /**
   * Start a sequence.
   */
  abstract function startSequence();
  
  /**
   * End a sequence.
   */
  abstract function endSequence();

  abstract function visit(value:ObjectValue);
  abstract function visit(value:ArrayValue);
  abstract function visit(value:NilValue);
  abstract function visit(value:BooleanValue);
  abstract function visit(value:IntegerValue);
  abstract function visit(value:RealValue);
  abstract function visit(value:StringValue);
  abstract function visit(value:BooleanVectorValue);
  abstract function visit(value:IntegerVectorValue);
  abstract function visit(value:RealVectorValue);
  abstract function visit(value:BooleanMatrixValue);
  abstract function visit(value:IntegerMatrixValue);
  abstract function visit(value:RealMatrixValue);
}

/**
 * Create a writer for a file.
 *
 * - path: Path of the file.
 *
 * Returns: the writer.
 *
 * The file extension of `path` is used to determine the precise type of the
 * returned object. Supported file extension are `.json` and `.yml`.
 */
function Writer(path:String) -> Writer {
  auto ext <- extension(path);
  result:Writer?;
  if ext == ".json" {
    writer:JSONWriter;
    writer.open(path);
    result <- writer;
  } else if ext == ".yml" {
    writer:YAMLWriter;
    writer.open(path);
    result <- writer;
  }
  if !result? {
    error("unrecognized file extension '" + ext + "' in path '" + path +
        "'; supported extensions are '.json' and '.yml'.");
  }
  return result!;
}
