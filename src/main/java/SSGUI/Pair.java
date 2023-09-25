package SSGUI;

import java.util.AbstractMap;

public class Pair<K, V> extends AbstractMap.SimpleEntry<K, V> {
  private static final long serialVersionUID = 6411527075103472113L;

  public Pair(K key, V value) {
    super(key, value);
  }
}
