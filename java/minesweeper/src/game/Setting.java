package game;

public class Setting {
	private int width;
	private int height;
	private int mineTotal;
	
	public Setting(int width, int height, int mineTotal) {
		super();
		this.width = width;
		this.height = height;
		this.mineTotal = mineTotal;
	}

	public int getWidth() {
		return width;
	}

	public int getHeight() {
		return height;
	}

	public int getMineTotal() {
		return mineTotal;
	}
}
