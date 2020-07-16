package game;

import player.Player;

public class Easy extends Game {
	private Player p;

	public Easy(Player p) {
		super(new Setting(7, 5, 5));
		this.p = p;
	}

	@Override
	public void win() {
		p.setEasySuccess(p.getEasySuccess() + 1);
		this.hideMine = false;
		
		clear();
		print();
		System.out.println("You win");
		scan.nextLine();
	}

	@Override
	public void lose() {
		p.setEasyFailed(p.getEasyFailed() + 1);
		this.hideMine = false;
		
		clear();
		print();
		System.out.println("You lose");
		scan.nextLine();
	}
}
