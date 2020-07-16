package game;

import static constants.Constants.VALID_TYPES;

public class GameObject {
	private String type;
	private Game game;
	private int number;
	boolean flagged;
	
	private static boolean isValidType(String type) {
		for (String validType : VALID_TYPES) {
			if(validType.equalsIgnoreCase(validType)) return true;
		}
		return false;
	}

	public GameObject(Game game, String type) {
		if(!isValidType(type))
			throw new IllegalArgumentException("invalid game object type");
		
		this.game = game;
		this.type = type;
		this.flagged = false;
	}
	
	public void setNumber(int number) {
		this.number = number;
	}
	
	public int getNumber() {
		return number;
	}
	
	public String getType() {
		return type;
	}
	
	public char toChar() {
		if(this.flagged) {
			return 'F';
		}
		
		if(type.equalsIgnoreCase("mine")) {
			return game.hideMine ? 'X' : 'M';
		}
		
		if(type.equalsIgnoreCase("not_open")) {
			return 'X';
		}
		
		if(type.equalsIgnoreCase("number")) {
			if(number == 0) return '-';
			return (char) ('0' + number);
		}
		
		throw new IllegalArgumentException();
	}
}
