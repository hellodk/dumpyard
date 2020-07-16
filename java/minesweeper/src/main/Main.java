package main;

import game.Easy;
import game.Game;
import game.Hard;
import player.Player;
import player.PlayerRepo;

import java.io.IOException;
import java.util.Scanner;

public class Main {

	public static void main(String[] args) throws IOException {
		new Main(new PlayerRepo());
	}
	
	public Main(PlayerRepo playerRepo) {
		Player p = playerRepo.loadOrNewPrompt();
		startGame(p, playerRepo);
	}

	private Scanner scan = new Scanner(System.in);
	private void startGame(Player p, PlayerRepo playerRepo) {
		clear();
		printInstructions(p);
		selectLevel(p);
		try {
			playerRepo.save();
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		startGame(p, playerRepo);
	}

	private  void clear()  {
		// for(int i = 0; i < 26; i++) System.out.println("");
		System.out.print("\033[H\033[2J"); // better way to clear the console
		System.out.flush();
	}

	private void selectLevel(Player p)
	{
		Game game;
		do {
			System.out.print("level [1-2]: ");
			String input = scan.nextLine();
			if(input.equalsIgnoreCase("exit")) {
				return;
			}
			try
			{
				int level = Integer.parseInt(input);
				if (level == 1) {
					game = new Easy(p);
					break;
				}
				if (level == 2) {
					game = new Hard(p);
					break;
				}
				else continue;
			} catch (Exception e) {
				continue;
			}
		} while(true);
		p.howToPlay();
		scan.nextLine();
		game.play();
	}

	private void printInstructions(Player p)
	{
		System.out.println("Welcome, " + p.getName());
		System.out.println("Your current record: ");
		System.out.println("Easy: Win: "+ p.getEasySuccess() + " | Lose: " + p.getEasyFailed());
		System.out.println("Hard: Win: "+ p.getHardSuccess() + " | Lose: " + p.getHardFailed());
		System.out.println("");

		System.out.println("Choose level: ");
		System.out.println("1. Easy (7 x 5, 5 mines)");
		System.out.println("2. Hard (12 x 9, 15 mines)");
		System.out.println("");

		System.out.println("Type 'exit' to exit from the game");
	}
}
