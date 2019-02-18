package ija;

import java.util.*;
import ija.gui.*;
import ija.model.*;
import javax.swing.*;
import java.io.*;

/**
 * Creating Solitaire game board
 *
 * @author xskurl01, xmicha65
 */
public class Solitaire implements Serializable {

    /**
     * Application main
     * create new MainFrame
     * and call new game
     * @param args arguments
     */
    public static void main(String[] args) {
        MainFrame main = new MainFrame();
        main.newGame();
    }

    private Stack<Card> closed;
    private Stack<Card> open;
    private CardStack[] targetPacks;
    private CardStack[] workingPacks;
    private AppFrame appFrame;
    private transient History history;

    /**
     * Initialize Solitaire game board
     */
    public Solitaire() {
        appFrame = new AppFrame(this);
        historyInit();

        workingPacks = new CardStack[7];
        for (int i = 0; i < workingPacks.length; i++) {
            workingPacks[i] = createWorkingPack(i);
        }

        targetPacks = new CardStack[4];
        for (int i = 0; i < targetPacks.length; i++) {
            targetPacks[i] = createTargetPack(i);
        }

        closed = new Stack<Card>();
        open = new Stack<Card>();
        closed = createCardDeck();

        workingPacks = new CardStack[7];
        for(int i = 0; i < 7; i++) {
            workingPacks[i] = createWorkingPack(i);
            for(int j = 0; j < i+1; j++) {
                workingPacks[i].set(closed.pop());
            }
        }
    }

    /**
     * Method for access game GUI
     * @return reference to game appFrame
     */
    public AppFrame getAppFrame() {
        return appFrame;
    }

    /**
     * Return board absolute width
     * @return board width
     */
    public int getBoardWidth() {
        return appFrame.BOARD_WIDTH;
    }

    /**
     * Return board absolute height
     * @return board height
     */
    public int getBoardHeight() {
        return appFrame.BOARD_HEIGHT;
    }

    /**
     * Create new target pack
     * @param number index of target pack
     * @return created target pack
     */
    public CardStack createTargetPack(int number) {
        CardStack stack = new CardStack("t" + number);
        return stack;
    }

    /**
     * Create new working pack
     * @param number index of working pack
     * @return created working pack
     */
    public CardStack createWorkingPack(int number) {
        CardStack stack = new CardStack("w" + number);
        return stack;
    }

    /**
     * Pop card from closed stack peek
     * @return card from peek
     */
    public Card closedPop() {
        if (closed.size() == 0) {
            return null;
        }
        return closed.peek();
    }

    /**
     * Pop card from open stack peek
     * @return card from peek
     */
    public Card openPop() {
        if (open.size() == 0) {
            return null;
        }
        return open.peek();
    }

    /**
     * Pop card from target pack peek
     * @param index targetPack index
     * @return card from peek
     */
    public Card targetPackPeek(int index) {
        if (targetPacks[index].isEmpty()) {
            return null;
        }
        return targetPacks[index].peek();
    }

    /**
     * Return working pack for GUI process
     * @param index index of working pack
     * @return working pack at specific index
     */
    public Stack<Card> getWorkingPack(int index) {
        return workingPacks[index].returnStack();
    }

    /**
     * Create standard deck of 52 cards and mix it
     * @return mixed card deck
     */
    public Stack<Card> createCardDeck() {
        CardDeck deck = new CardDeck();
        deck = deck.createCardDeck();
        deck.mix();
        return deck.returnStack();
    }

    /**
     * Move card from closed to open stack
     */
    public void openCard() {
        if (! closed.isEmpty()) {
                Card card = closed.pop();
                open.push(card);
                card.turnFaceUp();
        }
    }

    /**
     * Move all cards from open to closed stack
     */
    public void allToClosed() {
        int size = open.size();
        for(int i = 0; i < size; i++) {
            Card card = open.pop();
            card.turnFaceDown();
            closed.push(card);
        }
    }

    /**
     * Call specific functions of menu buttons
     * @param index index of selected button
     */
    public void onMenuClick(int index) {
        System.out.println("menu #" + index + " clicked");
        if (index == 4){ undo(); }
        else if (index == 5) { hint(); }
        else if (index == 6) { saveGame(); }
    }

    /**
     * Action called on click to closed stack - when is closed
     * stack empty call allToClosed() else openCard()
     */
    public void onClosedClick() {
        System.out.println("closed clicked");
        appFrame.unhint();
        appFrame.unselect();
        if (! appFrame.isOpenSelected() && ! appFrame.isWorkingPackSelected()) {
            if (closed.isEmpty()) {
                allToClosed();
                history.makeNote("allToClosed", null, null);
            }
            else {
                openCard();
                history.makeNote("openCard", null, null);
            }
        }
    }

    /**
     * Action called on click to open stack.
     */
    public void onOpenClick() {
        System.out.println("open clicked");
        appFrame.unhint();
        if (! open.isEmpty()) {
            if (! appFrame.isOpenSelected())
                appFrame.selectOpen();
            else
                appFrame.unselect();
        }
    }

    /**
     * Action called on click to target pack - check if
     * is already selected open stack or working pack
     * @param index index of target pack
     */
    public void onTargetPackClick(int index) {
        System.out.println("target #" + index + " clicked");
        appFrame.unhint();
        if (appFrame.isOpenSelected()) {
            if (targetPacks[index].tryTargetPack(open.peek())) {
                Card temp = open.pop();
                targetPacks[index].put(temp);

                Stack<Card> stack = new Stack<>();
                stack.push(temp);
                history.makeNote("open", targetPacks[index].name(), stack);

                appFrame.unselect();
                checkWin();
            }
        }
        if (appFrame.isWorkingPackSelected()) {
            CardStack pack = workingPacks[appFrame.selectedStack()];
            if (!pack.isEmpty()) {
                if (targetPacks[index].tryTargetPack(pack.peek())) {
                    Card temp = pack.pop();
                    targetPacks[index].put(temp);

                    Stack<Card> stack = new Stack<>();
                    stack.push(temp);
                    history.makeNote(workingPacks[appFrame.selectedStack()].name(), targetPacks[index].name(), stack);

                    if (! pack.isEmpty())
                        pack.peek().turnFaceUp();
                    appFrame.unselect();
                    checkWin();
                }
            }
        }
    }

    /**
     * Action called on click to working pack - check if
     * is already selected open stack or other working pack
     * @param index index of working pack
     */
    public void onWorkingPackClick(int index) {
        System.out.println("stack #" + index + " clicked");
        appFrame.unhint();
        if (appFrame.isOpenSelected()) {
            Card temp = open.peek();
            if (workingPacks[index].tryWorkingPack(temp)) {
                workingPacks[index].put(open.pop());
                workingPacks[index].peek().turnFaceUp();

                Stack<Card> stack = new Stack<>();
                stack.push(temp);
                history.makeNote("open", workingPacks[index].name(), stack);
            }
            appFrame.unselect();
            appFrame.selectWorkingPack(index);
        }
        else if (appFrame.isWorkingPackSelected()) {
            int firstWorkingPack = appFrame.selectedStack();
            if (index != firstWorkingPack) {
                Stack<Card> temp = removeFaceUpCards(firstWorkingPack);
                if (!temp.isEmpty()) {
                    if (workingPacks[index].tryWorkingPack(temp.peek())) {
                        Stack<Card> stack = new Stack<>();
                        stack.addAll(temp);
                        addToStack(temp, index);

                        history.makeNote(workingPacks[appFrame.selectedStack()].name(), workingPacks[index].name(), stack);

                        if (!workingPacks[firstWorkingPack].isEmpty())
                            workingPacks[firstWorkingPack].peek().turnFaceUp();
                        appFrame.unselect();
                    } else {
                        addToStack(temp, firstWorkingPack);
                        appFrame.unselect();
                        appFrame.selectWorkingPack(index);
                    }
                }
            }
            else
                appFrame.unselect();
        } else {
            appFrame.selectWorkingPack(index);
            workingPacks[index].peek().turnFaceUp();
        }
    }

    /**
     * Take face up cards from working pack
     * @param index index of working pack
     * @return stack of face up cards
     */
    private Stack<Card> removeFaceUpCards(int index) {
        Stack<Card> cards = new Stack<Card>();
        while (!workingPacks[index].isEmpty() &&
                workingPacks[index].peek().isTurnedFaceUp()) {
            cards.push(workingPacks[index].pop());
        }
        return cards;
    }

    /**
     * Add cards into working pack
     * @param cards stack of cards for add
     * @param index index of working pack
     */
    private void addToStack(Stack<Card> cards, int index) {
        while (! cards.isEmpty()) {
            workingPacks[index].put(cards.pop());
        }
    }

    /**
     * Method, which finds possible next move and highlights
     * cards or places available for the move.
     */
    public void hint() {
        appFrame.unselect();
        appFrame.unhint();
        Card card;

        if (!open.isEmpty()) {
            card = this.open.peek();
            for (int i = 0; i < 4; i++) {
                if (targetPacks[i].tryTargetPack(card)) {
                    appFrame.hintOpen(1);
                    appFrame.hintTargetPack(2, i);
                    return;
                }
            }
            for (int i = 0; i < 7; i++) {
                if (workingPacks[i].tryWorkingPack(card)) {
                    appFrame.hintOpen(1);
                    appFrame.hintWorkingPack(2, i);
                    return;
                }
            }
        }

        for(int i = 0; i < 7; i++) {
            if (!workingPacks[i].isEmpty()) {
                card = workingPacks[i].peek();
                for (int j = 0; j < 4; j++) {
                    if (targetPacks[j].tryTargetPack(card)) {
                        appFrame.hintWorkingPack(1, i);
                        appFrame.hintTargetPack(2, j);
                        return;
                    }
                }
            }
        }

        for(int i = 0; i < 7; i++) {
            if(!workingPacks[i].isEmpty()) {
                for(int j = 0; j < 7; j++) {
                    if(i != j && !workingPacks[j].isEmpty()) {
                        card = workingPacks[i].peek();
                        if (workingPacks[j].tryWorkingPack(card)) {
                            appFrame.hintWorkingPack(1, i);
                            appFrame.hintWorkingPack(2, j);
                            return;
                        }
                    }
                }
            }
        }

        appFrame.hintClosed();
    }

    /**
     * Method makes reversed latest move saved in history of moves,
     * and then delete the record.
     */
    public void undo() {
        appFrame.unselect();

        if (history.isEmpty())
            return;

        if (history.source() =="allToClosed") {
            while(!closed.isEmpty()) {
                open.push(closed.pop());
                open.peek().turnFaceUp();
            }
            history.removeLatest();
            return;
        }
        if (history.source() == "openCard") {
            closed.push(open.pop());
            closed.peek().turnFaceDown();
            history.removeLatest();
            return;
        }

        String source = history.source();
        String target = history.target();
        Stack<Card> cards = new Stack<>();
        cards.addAll(history.cards());

        if (source != "open") {
            int sourceIndex = Integer.parseInt(Character.toString(source.charAt(1)));
            int targetIndex = Integer.parseInt(Character.toString(target.charAt(1)));

            if(source.charAt(0) == 'w' && target.charAt(0) == 't') {
                workingPacks[sourceIndex].put(targetPacks[targetIndex].pop());
            }
            else {
                if(cards.size() == 1) {
                    workingPacks[sourceIndex].put(workingPacks[targetIndex].pop());
                }
                else {
                    while(!cards.isEmpty()) {
                        workingPacks[sourceIndex].put(cards.pop());
                        workingPacks[targetIndex].pop();
                    }
                }
            }
        }
        if (source == "open") {
            int targetIndex = Integer.parseInt(Character.toString(target.charAt(1)));
            if(target.charAt(0) == 'w') {
                open.push(workingPacks[targetIndex].pop());
            }
            else {
                open.push(targetPacks[targetIndex].pop());
            }
        }
        history.removeLatest();
    }

    /**
     * Open modal window to select file location,
     * then stream data into target file
     */
    public void saveGame() {
        JFileChooser fileChooser = new JFileChooser("dest-client");
        fileChooser.setDialogTitle("Save game");
        File file = null;
        if (fileChooser.showSaveDialog(appFrame) == JFileChooser.APPROVE_OPTION) {
            file = fileChooser.getSelectedFile();
        }
        System.out.println("saving to: " + file);
        FileOutputStream fos;
        ObjectOutputStream out;
        try {
            fos = new FileOutputStream(file);
            out = new ObjectOutputStream(fos);
            out.writeObject(this);
            out.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    /**
     * Open modal window for select file,
     * then stream data from loaded file
     * @return loaded game
     */
    public Solitaire loadGame() {
        JFileChooser fileChooser = new JFileChooser("dest-client");
        fileChooser.setDialogTitle("Load game");
        File file = null;
        if (fileChooser.showOpenDialog(appFrame) == JFileChooser.APPROVE_OPTION) {
            file = fileChooser.getSelectedFile();
        }
        System.out.println("loading from: " + file);
        FileInputStream fis;
        ObjectInputStream in;
        Solitaire temp = null;
        try {
            fis = new FileInputStream(file);
            in = new ObjectInputStream(fis);
            temp = (Solitaire) in.readObject();
            in.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        if(temp != null) {
            temp.historyInit();
            return temp;
        }
        return null;
    }

    /**
     * Initialize new history for board
     */
    private void historyInit() {
        this.history = new History();
    }

    /**
     * Check target packs if all have king on peek
     */
    private void checkWin() {
        boolean isWin = true;
        for (int i = 0; i < 4; i++) {
            Card card = targetPackPeek(i);
            if (card == null || card.value() != 13) {
                isWin = false;
            }
        }
        if (isWin)
            appFrame.gameWin();
    }
}
