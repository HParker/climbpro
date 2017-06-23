// IDEA:
// What about a piece struct like
// struct Piece { offset: (usize, usize), shape: [[i8; 3]; 3]}
// that way we can bitmash them together to see if they are overlapping.

// climb 12
extern crate rayon;
use rayon::prelude::*;
use std::time::{Duration, Instant};

type Shape = [[bool; 3]; 3];

#[derive(Clone)]
struct Piece {
    origin: (usize, usize),
    shape: Shape,
    movable: bool
}

const DOT: Shape = [
    [true, false, false],
    [false, false, false],
    [false, false, false]
];

const VTWO: Shape = [
    [true, false, false],
    [true, false, false],
    [false, false, false]
];

const FTWO: Shape = [
    [true, true, false],
    [false, false, false],
    [false, false, false]
];

const GOAL: Shape = [
    [false, true, false],
    [true, true, true],
    [false, false, false]
];

const LEFT: Shape = [
    [true, true, false],
    [true, false, false],
    [false, false, false]
];

const RIGHT: Shape = [
    [false, true, false],
    [true, true, false],
    [false, false, false]
];

#[derive(Clone)]
struct Board {
    pieces: Vec<Piece>,
    height: i8,
    width: i8
}

impl PartialEq for Board {
    fn eq(&self, other: &Board) -> bool {
        for (piece, other_piece) in self.pieces.iter().zip(other.pieces.iter()) {
            if piece.origin != other_piece.origin {
                return false;
            }
        }
        true
    }
}

fn initial_board() -> Board {
    Board { pieces: vec!(
              Piece { origin: (0,0), shape: FTWO, movable: false }, // top bar
              Piece { origin: (0,3), shape: FTWO, movable: false }, // top bar
              Piece { origin: (1,0), shape: VTWO, movable: true },
              Piece { origin: (1,4), shape: VTWO, movable: true },
              Piece { origin: (4,1), shape: GOAL, movable: true },
              Piece { origin: (2,1), shape: LEFT, movable: true },
              Piece { origin: (2,2), shape: RIGHT, movable: true },
              Piece { origin: (3,0), shape: DOT, movable: true },
              Piece { origin: (3,4), shape: DOT, movable: true },
              Piece { origin: (5,0), shape: DOT, movable: true },
              Piece { origin: (5,4), shape: DOT, movable: true },
              Piece { origin: (4,0), shape: FTWO, movable: true },
              Piece { origin: (4,3), shape: FTWO, movable: true }),
            height: 6,
            width: 5
    }
}


fn show(board: &Board) {
    let emoji = [
        "⬛",
        "⬛",
        "🍺",
        "🔴",
        "😍",
        "🔵",
        "💩",
        "💬",
        "⛩",
        "♥",
        "🤡",
        "☂",
        "😹"
    ];

    let mut drawing: [[&str; 5]; 6] = [["⬜"; 5]; 6];

    for (pid, piece) in board.pieces.iter().enumerate() {
        println!("id: {} {} ({}, {}) mov: {}", pid, emoji[pid], piece.origin.0, piece.origin.1, piece.movable);
        for (y, row) in piece.shape.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if cell == &true {
                    drawing[piece.origin.0 + y][piece.origin.1 + x] = emoji[pid]
                }
            }

        }
    }

    for row in drawing.iter() {
        for cell in row {
            print!(" {} ", cell);
        }
        print!("\n\n");
    }
}

fn valid(board: Board) -> bool {
    let mut area: [[bool; 5]; 6] = [[false; 5]; 6];
    let mut count = 0;
    for piece in board.pieces.iter() {
        for (y, row) in piece.shape.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if *cell && inbounds(piece.origin, y, x) {
                    if area[piece.origin.0 + y][piece.origin.1 + x] == false {
                        count += 1;
                        area[piece.origin.0 + y][piece.origin.1 + x] = true;
                    } else {
                        return false;
                    }
                }
            }
        }
    }
    if count == 26 {
        return true;
    }
    return false;
}

fn inbounds(location: (usize, usize), y: usize, x: usize) -> bool {
    location.0 + y < 6 && location.1 + x < 5
}

fn movements(piece: &Piece) -> Vec<Piece> {
    let mut new_pieces = vec!();
    if piece.origin.0 < 4 {
        new_pieces.push(Piece { origin: (piece.origin.0 + 1, piece.origin.1), shape: piece.shape, movable: true })
    }
    if piece.origin.1 < 3 {
        new_pieces.push(Piece { origin: (piece.origin.0, piece.origin.1 + 1), shape: piece.shape, movable: true })
    }
    if piece.origin.0 > 1 {
        new_pieces.push(Piece { origin: (piece.origin.0 - 1, piece.origin.1), shape: piece.shape, movable: true })
    }
    if piece.origin.1 > 1 {
        new_pieces.push(Piece { origin: (piece.origin.0, piece.origin.1 - 1), shape: piece.shape, movable: true })
    }
    new_pieces
}

fn replace(new_piece: Piece, location: usize, board: Board) -> Board {
    let mut new_board = board;
    new_board.pieces[location] = new_piece;
    new_board
}

fn potential_boards(board: Board) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    for (i, piece) in board.pieces.iter().enumerate().filter(|p| p.1.movable) {
        for moved_piece in movements(piece) {
            let new_board: Board = replace(moved_piece, i, board.clone());
            if valid(new_board.clone()) {
                potentials.push(new_board.clone());
            }

        }
    }
    potentials
}

fn expand_layer(boards: Vec<Board>, previous: Vec<Vec<Board>>) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    let mut pboards: Vec<Vec<Board>> = boards.par_iter().map(|board| potential_boards(board.clone())).collect();

    for mut boards in pboards {
        boards.retain(|b| (previous.iter().find(|pb| pb.contains(&b)).is_none()));
        potentials.append(&mut boards)
    }
    potentials
}

fn main() {
    let now = Instant::now();
    let mut layer: Vec<Board> = vec!(initial_board());
    let mut layers: Vec<Vec<Board>> = vec!(layer.clone());
    loop {
        layer = expand_layer(layer.clone(), layers.clone());

        layers.push(layer.clone());
        println!("layer {} size: {} | {} s", layers.len(), layer.len(), now.elapsed().as_secs());
    }

}
