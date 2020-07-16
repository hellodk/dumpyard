package player;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Scanner;
import java.util.Vector;

import static constants.Constants.N_PER_PAGE;
import static constants.Constants.TWENTY_SIX;

public class PlayerRepo {
	private static String FILE_NAME = "data/player.csv"; // refactored
	private Vector<Player> players = new Vector<Player>();

	private Scanner scan = new Scanner(System.in);

	private int page = 0;

	public PlayerRepo() throws IOException {
		loadProfiles();
	}
	
	public void loadProfiles() throws IOException {		
		File file = new File(FILE_NAME);
		if(!file.exists()) {
			file.getParentFile().mkdirs();
			file.createNewFile();
			return;
		}
		
		FileReader fr = new FileReader(file);
		BufferedReader br = new BufferedReader(fr);
		
		String line = br.readLine();
		while(line != null) {
			Player p = Player.fromText(line);
			line = br.readLine();
			players.add(p);
		}
		
		br.close();
	}

	public Player loadOrNewPrompt() {		
		if(players.size() == 0) {
			return createNewProfilePrompt();
		}

		do {
			for(int i = 0; i < TWENTY_SIX; i++) System.out.println("");
			selectProfile(); // Refactored
			System.out.println("type 'new' to create new profile");
			int startIdx = (page * N_PER_PAGE + 1);
			int endIdx = startIdx + N_PER_PAGE - 1;
			if(endIdx >= players.size()) endIdx = players.size();
			
			System.out.print("choose using ["+startIdx+"-"+endIdx+"]: ");
			String input = scan.nextLine();
			if(input.equalsIgnoreCase("it")) {
				page++;
				continue;
			}
			
			if(input.equalsIgnoreCase("new")) {
				return createNewProfilePrompt();
			}
			
			try {
				int choose = Integer.parseInt(input);
				if(choose < startIdx || choose > endIdx) continue;
				return players.elementAt(choose-1);
			} catch (NumberFormatException e) {
				continue;
			}
		} while(true);
	}

	private void selectProfile() {
		System.out.println("Choose profile: ");
		for (int i = 0; i < N_PER_PAGE; i++) {
			int idx = page * N_PER_PAGE + i;
			if(idx >= players.size()) break;

			Player p = players.elementAt(idx);
			System.out.println((idx+1) + ". " + p.getName());
		}

		System.out.println("");
		if(players.size() > N_PER_PAGE) {
			System.out.println("type 'it' to next page");
		}
	}


	private Player createNewProfilePrompt() {
		String name = "";
		
		do {
			System.out.print("insert your name [3-12 chars]: ");
			name = scan.nextLine();
		} while(name.length() < 3 || name.length() > 12);
		
		Player p = new Player(name);
		createNewProfile(p);
		return p;
	}
	
	private void createNewProfile(Player p) {
		try {
			write(p);
			players.add(p);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private void write(Player p) throws IOException {
		File file = new File(FILE_NAME);
		if(!file.exists()) {
			file.getParentFile().mkdirs();
			file.createNewFile();
			return;
		}
		
		FileWriter fw = new FileWriter(file, true);
		BufferedWriter bw = new BufferedWriter(fw);
		
		bw.write(p.toText());
		bw.newLine();
		bw.close();
	}
	
	public void save() throws IOException {
		File file = new File(FILE_NAME);
		if(!file.exists()) {
			file.getParentFile().mkdirs();
			file.createNewFile();
			return;
		}
		
		FileWriter fw = new FileWriter(file);
		BufferedWriter bw = new BufferedWriter(fw);
		
		for (Player player : players) {
			bw.write(player.toText());
			bw.newLine();
		}
		bw.close();
	}
}
