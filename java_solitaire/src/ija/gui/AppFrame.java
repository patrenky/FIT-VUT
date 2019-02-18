package ija.gui;

import ija.model.*;
import ija.Solitaire;

import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.io.File;
import java.util.Stack;

/**
 * Creating GUI elements and grid of one Solitaire game
 *
 * @author Patrik Michalak - xmicha65
 */
public class AppFrame extends JComponent implements MouseListener {

    // grid sizes
    private static final int OFFSET = 5;

    private static final int MENU_HEIGHT = 25;
    private static final int MENU_OFFSET = 5;

    private static final int CARD_WIDTH = 70;
    private static final int CARD_HEIGHT = 95;
    private static final int FACEUP_OFFSET = 15;
    private static final int FACEDOWN_OFFSET = 3;

    private static final int COL = OFFSET + CARD_WIDTH;
    private static final int MENU_ROW = OFFSET + MENU_HEIGHT;
    private static final int CARD_ROW = OFFSET + CARD_HEIGHT;

    public static final int BOARD_WIDTH = 7 * COL + OFFSET;
    public static final int BOARD_HEIGHT = MENU_HEIGHT + 2 * CARD_ROW + OFFSET + 7 * FACEDOWN_OFFSET + 13 * FACEUP_OFFSET;

    // grid orientation
    private int selectedRow = -1;
    private int selectedCol = -1;
    private int hintRow1 = -1;
    private int hintCol1 = -1;
    private int hintRow2 = -1;
    private int hintCol2 = -1;

    private boolean gameWin = false;

    private final JPanel panel;
    private Solitaire board;

    /**
     * Initialize board JFrame
     * @param board created Solitaire object
     */
    public AppFrame(Solitaire board) {
        this.board = board;
        this.addMouseListener(this);
        panel = new JPanel();
        panel.setPreferredSize(new Dimension(getWidth(), getHeight()));
        panel.setVisible(true);
    }

    /**
     * Swing method, create board graphics components:
     * backgrounds, borders, card and menu images
     * at specific positions.
     * @param g Swing Graphics
     */
    public void paintComponent(Graphics g) {
        // board background
        g.setColor(new Color(50, 153, 50));
        g.fillRect(0, 0, getWidth(), getHeight());

        // board border
        g.setColor(Color.BLACK);
        g.drawRect(0, 0, BOARD_WIDTH, BOARD_HEIGHT);

        // menu
        String[] menuItems = {"Undo", "Hint", "Save"};
        for (int i = 0; i < 3; i++) {
            drawMenuItem(g, "btn" + menuItems[i], OFFSET + COL * (i + 4), OFFSET);
        }

        // closed
        drawCard(g, board.closedPop(), OFFSET, MENU_ROW + OFFSET);
        if (hintRow1 == 1 && hintCol1 == 0)
            hintCardBorder(g, OFFSET, MENU_ROW + OFFSET);

        // open
        drawCard(g, board.openPop(), COL + OFFSET, MENU_ROW + OFFSET);
        if (selectedRow == 1 && selectedCol == 1)
            selectedCardBorder(g, COL + OFFSET, MENU_ROW + OFFSET);
        else if ((hintRow1 == 1 && hintCol1 == 1) || (hintRow2 == 1 && hintCol2 == 1))
            hintCardBorder(g, COL + OFFSET, MENU_ROW + OFFSET);

        // target
        for (int i = 0; i < 4; i++) {
            drawCard(g, board.targetPackPeek(i), (i + 3) * COL + OFFSET, MENU_ROW + OFFSET);
            if ((hintRow1 == 1 && hintCol1 == i + 3) || (hintRow2 == 1 && hintCol2 == i + 3))
                hintCardBorder(g, (i + 3) * COL + OFFSET, MENU_ROW + OFFSET);
        }

        // stacks
        for (int i = 0; i < 7; i++) {
            Stack<Card> pile = board.getWorkingPack(i);
            int cardOffset = 0;
            for (int j = 0; j < pile.size(); j++) {
                drawCard(g, pile.get(j), i * COL + OFFSET, MENU_ROW + CARD_ROW + OFFSET + cardOffset);
                if (selectedRow == 2 && selectedCol == i && j == pile.size() - 1)
                    selectedCardBorder(g, i * COL + OFFSET, MENU_ROW + CARD_ROW + OFFSET + cardOffset);
                else if ((hintRow1 == 2 && hintCol1 == i) || (hintRow2 == 2 && hintCol2 == i))
                    hintCardBorder(g, i * COL + OFFSET, MENU_ROW + CARD_ROW + OFFSET + cardOffset);

                if (pile.get(j).isTurnedFaceUp())
                    cardOffset += FACEUP_OFFSET;
                else
                    cardOffset += FACEDOWN_OFFSET;
            }
        }

        // win game
        if (gameWin)
            drawWinGame(g);
    }

    /**
     * Load and draw menu item images
     * @param g Swing Graphic
     * @param name name of image file
     * @param x horizontal position in board
     * @param y vertical position on board
     */
    private void drawMenuItem(Graphics g, String name, int x, int y) {
        String fileName = "/ija/imgs/" + name + ".gif";
        Image image = new ImageIcon(getClass().getResource(fileName)).getImage();
        g.drawImage(image, x + MENU_OFFSET, y, CARD_WIDTH - 2 * MENU_OFFSET, MENU_HEIGHT, null);
    }

    /**
     * Load and draw cards images
     * @param g Swing Graphic
     * @param card Card object for draw
     * @param x horizontal position in board
     * @param y vertical position on board
     */
    private void drawCard(Graphics g, Card card, int x, int y) {
        if (card != null) {
            String fileName = card.getFileName();
            Image image = new ImageIcon(getClass().getResource(fileName)).getImage();
            g.drawImage(image, x, y, CARD_WIDTH, CARD_HEIGHT, null);
        } else {
            // placeholder border
            g.setColor(Color.BLACK);
            g.drawRect(x, y, CARD_WIDTH, CARD_HEIGHT);
        }
    }

    /**
     * Load and draw win game image
     * @param g Swing Graphic
     */
    private void drawWinGame(Graphics g) {
        String fileName = "/ija/imgs/win.gif";
        Image image = new ImageIcon(getClass().getResource(fileName)).getImage();
        g.drawImage(image, 2 * COL, MENU_ROW + CARD_ROW + OFFSET, 3 * COL, CARD_ROW, null);
    }

    /**
     * Draw 3-lines yellow border around selected card
     * @param g Swing Graphic
     * @param x horizontal position in board
     * @param y vertical position on board
     */
    private void selectedCardBorder(Graphics g, int x, int y) {
        g.setColor(Color.YELLOW);
        g.drawRect(x, y, CARD_WIDTH, CARD_HEIGHT);
        g.drawRect(x + 1, y + 1, CARD_WIDTH - 2, CARD_HEIGHT - 2);
        g.drawRect(x + 2, y + 2, CARD_WIDTH - 4, CARD_HEIGHT - 4);
    }

    /**
     * Draw 2-lines blue border around card hint
     * @param g Swing Graphic
     * @param x horizontal position in board
     * @param y vertical position on board
     */
    private void hintCardBorder(Graphics g, int x, int y) {
        g.setColor(Color.BLUE);
        g.drawRect(x, y, CARD_WIDTH, CARD_HEIGHT);
        g.drawRect(x + 1, y + 1, CARD_WIDTH - 2, CARD_HEIGHT - 2);
    }

    // mouse listeners
    public void mouseExited(MouseEvent e) {
    }

    public void mouseEntered(MouseEvent e) {
    }

    public void mouseReleased(MouseEvent e) {
    }

    public void mousePressed(MouseEvent e) {
    }

    /**
     * Create grid on board (rows and cols)
     * and listeners on specific positions
     * @param e mouse position on board
     */
    public void mouseClicked(MouseEvent e) {
        // grid
        int col = e.getX() / COL;
        if (col > 6)
            col = 6;

        int row;
        if (e.getY() < MENU_ROW)
            row = 0;
        else if (e.getY() > MENU_ROW && e.getY() < MENU_ROW + CARD_ROW)
            row = 1;
        else
            row = 2;

        // grid listener
        if (row == 0)
            board.onMenuClick(col);
        else if (row == 1 && col == 0)
            board.onClosedClick();
        else if (row == 1 && col == 1)
            board.onOpenClick();
        else if (row == 1 && col >= 3)
            board.onTargetPackClick(col - 3);
        else if (row == 2)
            board.onWorkingPackClick(col);
        repaint();
    }

    /**
     * Check if open stack is selected
     * @return boolean value
     */
    public boolean isOpenSelected() {
        return selectedRow == 1 && selectedCol == 1;
    }

    /**
     * Check if working pack is selected
     * @return boolean value
     */
    public boolean isWorkingPackSelected() {
        return selectedRow == 2;
    }

    /**
     * Check on which grid column is selected stack
     * @return index of selected stack
     */
    public int selectedStack() {
        if (selectedRow == 2)
            return selectedCol;
        else
            return -1;
    }

    /**
     * Reset select position values
     */
    public void unselect() {
        selectedRow = -1;
        selectedCol = -1;
    }

    /**
     * Set select position values to open stack
     */
    public void selectOpen() {
        selectedRow = 1;
        selectedCol = 1;
    }

    /**
     * Set select position values to specific working pack
     * @param index index of working pack
     */
    public void selectWorkingPack(int index) {
        selectedRow = 2;
        selectedCol = index;
    }

    /**
     * Reset hint position values
     */
    public void unhint() {
        hintRow1 = -1;
        hintCol1 = -1;
        hintRow2 = -1;
        hintCol2 = -1;
    }

    /**
     * Set hint position values to open stack
     * @param num order of hinted stack
     */
    public void hintOpen(int num) {
        if (num == 1) {
            hintRow1 = 1;
            hintCol1 = 1;
        } else {
            hintRow2 = 1;
            hintCol2 = 1;
        }
    }

    /**
     * Set hint position values to closed stack
     */
    public void hintClosed() {
        hintRow1 = 1;
        hintCol1 = 0;
        hintRow2 = 1;
        hintCol2 = 0;
    }

    /**
     * Set hint position values to specific working pack
     * @param num order of hinted pack
     * @param index index of working pack
     */
    public void hintWorkingPack(int num, int index) {
        if (num == 1) {
            hintRow1 = 2;
            hintCol1 = index;
        } else {
            hintRow2 = 2;
            hintCol2 = index;
        }
    }

    /**
     * Set hint position values to specific target pack
     * @param num order of hinted pack
     * @param index index of target pack
     */
    public void hintTargetPack(int num, int index) {
        if (num == 1) {
            hintRow1 = 1;
            hintCol1 = index + 3;
        } else {
            hintRow2 = 1;
            hintCol2 = index + 3;
        }
    }

    /**
     * Set boolean flag gameWin to true
     */
    public void gameWin() {
        gameWin = true;
    }
}
