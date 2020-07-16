package player;

import java.util.UUID;
import java.util.Vector;

import static constants.Constants.TWENTY_SIX;

public class Player {
	private UUID id;
	private String name;
	
	private Easy easy;
	private Hard hard;
	
	private Player() {
		this.easy = new Easy();
		this.hard = new Hard();
	}
	
	public Player(String name) {
		this.id = UUID.randomUUID();
		this.name = name;
		this.easy = new Easy();
		this.hard = new Hard();
	}
	
	public UUID getId() {
		return id;
	}
	
	public String getName() {
		return name;
	}
	
	public void setEasyFailed(int easyFailed) {
		this.easy.setLose(easyFailed);
	}
	
	public void setEasySuccess(int easySuccess) {
		this.easy.setWin(easySuccess);
	}
	
	public void setHardFailed(int hardFailed) {
		this.hard.setLose(hardFailed);
	}
	
	public void setHardSuccess(int hardSuccess) {
		this.hard.setWin(hardSuccess);
	}
	
	public int getEasyFailed() {
		return easy.getLose();
	}
	
	public int getEasySuccess() {
		return easy.getWin();
	}
	
	public int getHardFailed() {
		return hard.getLose();
	}
	
	public int getHardSuccess() {
		return hard.getWin();
	}
	
	public String toText() {
		Vector<String> data = new Vector<String>();
		data.add(id.toString());
		data.add(name);
		
		data.add("easy#" + easy.getLose() + "#" + easy.getWin());
		data.add("hard#" + hard.getLose() + "#" + hard.getWin());
		
		return String.join(",", data);
	}
	
	public static Player fromText(String text) {
		Player p = new Player();
		String[] data = text.split(",");
		
		RuntimeException e = new RuntimeException("failed parse profile from text");
		if(data.length < 2) throw e;
		
		p.id = UUID.fromString(data[0]);
		p.name = data[1];
		
		for(int i = 2; i < data.length; i++) {
			String[] data2 = data[i].split("#");
			if(data2.length != 3) throw e;
			
			String type = data2[0];
			
			try {
				if(type.equalsIgnoreCase("easy")) {
					p.easy.setLose(Integer.parseInt(data2[1]));
					p.easy.setWin(Integer.parseInt(data2[2]));
				} else if(type.equalsIgnoreCase("hard")) {
					p.hard.setLose(Integer.parseInt(data2[1]));
					p.hard.setWin(Integer.parseInt(data2[2]));
				}
			} catch (NumberFormatException e2) {
				throw e;
			}
		}
		
		return p;
	}

	public void howToPlay() {
		for(int i = 0; i < TWENTY_SIX; i++) System.out.println("");
		printInstructions(); // Refactored
	}

	private void printInstructions() {
		System.out.println("Mines will be hidden on the closed squares");
		System.out.println("");
		System.out.println("If you open square with a mine inside, you lose");
		System.out.println("If you open all squares except mines, you win");
		System.out.println("");
		System.out.println("Open square using coordinate, example: E4");
		System.out.println("After opening, opened square can have a number. The number represents total mine(s) around the square");
		System.out.println("You can use 'switch' to switch to flagging command");
		System.out.println("Flagged square temporarily cannot be opened, until you unflagged it");
		System.out.println("Strategically, use flag when you sure the square is a mine. So you cannot accidentally open it");
		System.out.println("");
		System.out.println("Symbol Legend: ");
		symbolsLegend();
		System.out.println("");
		System.out.println("Press ENTER to start the game");
	}

	public void symbolsLegend() {
		System.out.println("'X' = Closed square");
		System.out.println("'M' = Mine");
		System.out.println("'F' = Flag");
		System.out.println("'-' = Open square without mine around");
		System.out.println("number 1 to 8 = Open square with N mine(s) around");
	}
}
