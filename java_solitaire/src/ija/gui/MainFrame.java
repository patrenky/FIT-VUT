package ija.gui;

import ija.Solitaire;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;

/**
 * Creating JFrame and control elements
 *
 * @author Patrik Michalak - xmicha65
 */
public class MainFrame extends JComponent {

    private Solitaire[] solitaire = new Solitaire[4];
    private int gamesCount = 0;

    private final JFrame frame;
    private final JMenuBar menuBar;
    private final JMenu quitMenu = new JMenu("Give up");
    private final JMenuItem[] quitMenuItem = new JMenuItem[4];

    /**
     * Initialize main Jframe and menu
     */
    public MainFrame() {
        System.out.println("init main frame");
        frame = new JFrame("Solitaire");
        frame.setLayout(new GridLayout(1, 1));
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        menuBar = new JMenuBar();
        JMenu menu;
        JMenuItem menuItem;
        menu = new JMenu("Game");
        menuItem = new JMenuItem("New game");
        menuItem.addActionListener((ActionEvent e) -> {
            newGame();
        });
        menu.add(menuItem);
        menuItem = new JMenuItem("Load game");
         menuItem.addActionListener((ActionEvent e) -> {
             Solitaire temp = solitaire[0].loadGame();
             if (temp != null) {
                 newGameLoad(temp);
                 SwingUtilities.updateComponentTreeUI(frame);
             }
         });
        menu.add(menuItem);
        menu.addSeparator();
        menuItem = new JMenuItem("Quit");
        menuItem.addActionListener((ActionEvent e) -> {
            frame.setVisible(false);
            System.exit(0);
        });
        menu.add(menuItem);
        menuBar.add(menu);
        menuBar.add(quitMenu);

        frame.setJMenuBar(menuBar);

        frame.setResizable(false);
        frame.pack();
        frame.setVisible(true);
    }

    /**
     * Create new solitaire game into JFrame
     */
    public void newGame() {
        if (gamesCount < 4) {
            System.out.println("new game #" + gamesCount);
            solitaire[gamesCount] = new Solitaire();
            if (gamesCount == 0)
                frame.setPreferredSize(new Dimension(solitaire[0].getBoardWidth(), solitaire[0].getBoardHeight()));
            if (gamesCount > 0)
                frame.setPreferredSize(new Dimension(2 * solitaire[0].getBoardWidth(), 2 * solitaire[0].getBoardHeight()));
            if (gamesCount > 1)
                frame.setLayout(new GridLayout(2, 2));
            addMenuItem(gamesCount);
            frame.add(solitaire[gamesCount].getAppFrame());
            frame.repaint();
            gamesCount++;
            frame.pack();
        }
    }

    /**
     * Load solitaire game into JFrame
     * @param newGame loaded game (Solitaire object)
     */
    public void newGameLoad(Solitaire newGame) {
        if (gamesCount < 4) {
            System.out.println("new game #" + gamesCount);
            solitaire[gamesCount] = newGame;
            if (gamesCount == 0)
                frame.setPreferredSize(new Dimension(solitaire[0].getBoardWidth(), solitaire[0].getBoardHeight()));
            if (gamesCount > 0)
                frame.setPreferredSize(new Dimension(2 * solitaire[0].getBoardWidth(), 2 * solitaire[0].getBoardHeight()));
            if (gamesCount > 1)
                frame.setLayout(new GridLayout(2, 2));
            addMenuItem(gamesCount);
            frame.add(solitaire[gamesCount].getAppFrame());
            frame.repaint();
            gamesCount++;
            frame.pack();
        }
    }

    /**
     * Add menuItem into menu when new game
     * @param index index of solitaire game
     */
    private void addMenuItem(int index){
        quitMenuItem[index] = new JMenuItem("Game " + (index + 1));
        quitMenuItem[index].addActionListener((ActionEvent e) -> {
            quitGame(index);
        });
        quitMenu.add(quitMenuItem[index]);
    }

    /**
     * Quit solitaire game on given index
     * @param index index of solitaire game
     */
    public void quitGame(int index) {
        System.out.println("quit game #" + index);
        if (gamesCount > 0 && index < 4) {
            tidyUp(index);
            frame.repaint();
            gamesCount--;
            if (gamesCount < 3) {
                frame.setLayout(new GridLayout(1, 1));
            }
            if (gamesCount == 1) {
                frame.setPreferredSize(new Dimension(solitaire[0].getBoardWidth(), solitaire[0].getBoardHeight()));
            }
            else if (gamesCount == 0) {
                frame.setVisible(false);
                System.exit(0);
            }
            frame.pack();
        }
    }

    /**
     * Tidy up Solitaire[] and MenuItem[] arrays
     * when quit solitaire game on given index
     * @param index index of solitaire game
     */
    private void tidyUp(int index) {
        frame.remove(solitaire[index].getAppFrame());
        for (int i = index; i < gamesCount; i++){
            quitMenu.remove(quitMenuItem[i]);
            if (i < gamesCount - 1) {
                addMenuItem(i);
                solitaire[i] = solitaire[i + 1];
            }
        }
    }
}
