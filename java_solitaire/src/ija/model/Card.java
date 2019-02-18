package ija.model;

import java.io.Serializable;
import java.util.Objects;

/**
* Class containing elements of card - value, color,
* and methods for card.
*
* @author Adam Skurla - xskurl01
*/
public class Card implements Serializable {
    private int value;
    private Color color;
    private boolean isTurnedUp;
    private static final String[] cardName = {
            "", "A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"
    };

    /**
    * Constructor sets value and color of card, and turns it face down.
    * @param c farba karty
    * @param value hodnota karty
    */
    public Card(Color c, int value) {
        this.color = c;
        this.value = value;
        this.isTurnedUp = false;
    }

    /**
    * Types of colors, which can card have.
    */
    public static enum Color {
        CLUBS("C"),
        DIAMONDS("D"),
        HEARTS("H"),
        SPADES("S");

        private String color;
        Color(String col) {
            this.color = col;
        }
        @Override
        public String toString() {
            return this.color;
        }
    }

    /**
    * Returns color of card
    * @return card color
    */
    public Color color() {
        return this.color;
    }

    /**
    * Returns true if card is face up, otherwise false.
    * @return is turned up
    */
    public boolean isTurnedFaceUp() {
        return this.isTurnedUp;
    }

    /**
    * Returns true if card has same color as argument card.
    * @param c argument card
    * @return same color
    */
    public boolean similarColorTo(Card c) {
        if (this.color == Color.CLUBS || this.color == Color.SPADES) {
            if (c.color == Color.CLUBS || c.color == Color.SPADES) {
                return true;
            }
        }
        if (this.color == Color.DIAMONDS || this.color == Color.HEARTS) {
            if (c.color == Color.DIAMONDS || c.color == Color.HEARTS) {
                return true;
            }
        }
        return false;
    }

    /**
    * Turns card face up, returns success of operation.
    * @return success of operation
    */
    public boolean turnFaceUp() {
        if (!(isTurnedUp)) {
            this.isTurnedUp = true;
            return true;
        }
        return false;
    }

    /**
    * Turns card face down, returns success of operation.
    * @return success of operation
    */
    public boolean turnFaceDown() {
        if (isTurnedUp) {
            this.isTurnedUp = false;
            return true;
        }
        return false;
    }

    /**
    * Returns value of card
    * @return card value
    */
    public int value() {
        return this.value;
    }

    @Override
    public String toString() {
        String turn;
        if (isTurnedUp) {
            turn = "U";
        } else {
            turn = "D";
        }
        return (Card.cardName[this.value] + "(" + this.color + ")" + turn);
    }

    @Override
    public boolean equals(Object o) {
        if (!(o instanceof Card)) {
            return false;
        }
        Card card = (Card) o;
        return card.value == this.value && card.color == this.color;
    }

    @Override
    public int hashCode() {
        return Objects.hash(this.color, this.value);
    }

    /**
    * Returns name of file, which belongs to the card.
    * @return file name
    */
    public String getFileName() {
        if (isTurnedFaceUp())
            return "/ija/imgs/" + value + color.toString() + ".gif";
        return "/ija/imgs/back.gif";
    }
}
