package game;

import java.util.Random;
import java.util.Scanner;

import static constants.Constants.TWENTY_SIX;

public abstract class Game {
	protected Setting gameSetting;
	boolean hideMine;
	private GameObject[][] board; 

	public abstract void win();
	public abstract void lose();
	
	public Game(Setting gameSetting) {
		this.gameSetting = gameSetting;
		this.hideMine = true;
		
		//fill board with not_open object 
		int h = gameSetting.getHeight();
		int w = gameSetting.getWidth();
		this.board = new GameObject[h][w];
		for(int i = 0; i < h; i++) {
			for(int j = 0; j < w; j++) {
				this.board[i][j] = new GameObject(this, "not_open");
			}
		}
		
		//place mines to board
		int placed = 0;
		Random random = new Random();
		while(placed < gameSetting.getMineTotal()) {
			int y = random.nextInt(h);
			int x = random.nextInt(w);
			
			if(board[y][x].getType().equalsIgnoreCase("mine")) {
				continue;
			}
			
			board[y][x] = new GameObject(this, "mine");
			++placed;
		}
	}
	
	private boolean placingFlag = false;
	protected Scanner scan = new Scanner(System.in);

	public void play() {
		clear();
		print();
		checkPlacingFlag(); // Refactored code
		gameInputs();
		play();
	}

	private void gameInputs() {
		do {
			System.out.print("Input coordinate to command: ");
			String input = scan.nextLine().trim();
			if(input.equalsIgnoreCase("switch")) {
				placingFlag = !placingFlag;
				break;
			}
			if(input.length() != 2) {
				System.out.println("invalid coordinate");
				continue;
			}

			int x = input.charAt(0) - 'A';
			int y = input.charAt(1) - '1';

			if(x < 0 || x >= gameSetting.getWidth() || y < 0 || y >= gameSetting.getHeight()) {
				System.out.println("invalid coordinate");
				continue;
			}
			if(!placingFlag) {
				if(board[y][x].flagged){
					System.out.println("cannot open flagged square");
					continue;
				}
				if(board[y][x].getType().equalsIgnoreCase("mine")) {
					this.lose();
					return;
				}
				open(x, y);
				if(isWin()) {
					this.win();
					return;
				}
			} else {
				if(board[y][x].getType().equalsIgnoreCase("number")) {
					System.out.println("opened squared cannot be flagged");
					continue;
				}
				board[y][x].flagged = !board[y][x].flagged;
			}
			break;
		}while(true);
	}

	private void checkPlacingFlag() {
		if(placingFlag) {
			System.out.println("currently your command is for placing/unplacing flag. Type 'switch' to start opening squares");
		} else {
			System.out.println("currently your command is for opening square. Type 'switch' to placing flag");
		}
	}

	private boolean isWin() {
		int h = gameSetting.getHeight();
		int w = gameSetting.getWidth();
		for(int i = 0; i < h; i++) {
			for(int j = 0; j < w; j++) {
				if(this.board[i][j].getType().equalsIgnoreCase("not_open")) {
					return false;
				}
			}
		}
		return true;
	}
	
	private void open(int x, int y) {
		int w = gameSetting.getWidth();
		int h = gameSetting.getHeight();
		if(x < 0 || x >= w || y < 0 || y >= h) return; 
		if(!board[y][x].getType().equalsIgnoreCase("not_open")) return;
		
		GameObject newObj = new GameObject(this, "number");
		
		int mineSurrounding = 0;
		for(int i = -1; i <= 1; i++) {
			for(int j = -1; j <= 1; j++) {
				int x2 = x + j;
				int y2 = y + i;
				if(x2 < 0 || x2 >= w || y2 < 0 || y2 >= h) continue; 
				if(board[y2][x2].getType().equalsIgnoreCase("mine")) {
					++mineSurrounding;
				}
			}
		}

		newObj.setNumber(mineSurrounding);
		board[y][x] = newObj;
		
		if(mineSurrounding == 0) {
			open(x-1, y);
			open(x+1, y);
			open(x, y-1);
			open(x, y+1);
			open(x-1, y-1);
			open(x-1, y+1);
			open(x+1, y-1);
			open(x+1, y+1);
		}
	}
	
	protected void clear() {
		for(int i = 0; i < TWENTY_SIX; i++) {
			System.out.println("");
		}
/*		System.out.print("\033[H\033[2J"); // better way to clear the console
		System.out.flush();*/
	}
	
	protected void print() {
		int h = gameSetting.getHeight();
		int w = gameSetting.getWidth();
		for(int i = 0; i < h; i++) {
			for(int j = 0; j < w; j++) {
				System.out.print(board[i][j].toChar());
			}
			System.out.println(" " + (i + 1));
		}
		for(int i = 0; i < w; i++) {
			System.out.print((char) ('A' + i));
		}
		System.out.println("");
		System.out.println("");
	}
}
