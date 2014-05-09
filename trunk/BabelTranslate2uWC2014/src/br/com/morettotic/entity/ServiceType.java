package br.com.morettotic.entity;

public enum ServiceType {
	Other(3),
    Health(2),
    Security(1),
    Tourism(4),
    Shop(5);
	
	private final int value;

    private ServiceType(int value) {
        this.value = value;
    }
    public int getValue() {
        return value;
    }
}
