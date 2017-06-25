#![cfg_attr(feature="clippy", feature(plugin))]

#![cfg_attr(feature="clippy", plugin(clippy))]
use std::time::{Instant};



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
        println!();
        println!();
    }
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

fn replace(new_piece: Piece, location: usize, board: &mut Board) {
    board.pieces[location] = new_piece;
}

fn area_for(pieces: &[Piece], ignore_location: usize) -> [[bool; 5]; 6] {
    let mut area: [[bool; 5]; 6] = [[false; 5]; 6];
    for (i, piece) in pieces.iter().enumerate() {
        if i == ignore_location {
            continue;
        }
        for (y, row) in piece.shape.iter().enumerate() {
            for (x, cell) in row.iter().enumerate() {
                if *cell && inbounds(piece.origin, y, x) {
                    area[piece.origin.0 + y][piece.origin.1 + x] = true;
                }
            }
        }
    }
    area
}

fn valid(piece: &Piece, area: &[[bool; 5]; 6]) -> bool {
    for (y, row) in piece.shape.iter().enumerate() {
        for (x, cell) in row.iter().enumerate() {
            if *cell && (!inbounds(piece.origin, y, x) || area[piece.origin.0 + y][piece.origin.1 + x]) {
                // println!("disqualified due to out of bounds");
                return false;
            }
        }
    }
    true
}

fn potential_boards(board: &Board) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    for (i, piece) in board.pieces.iter().enumerate().filter(|p| p.1.movable) {
        let area: [[bool; 5]; 6] = area_for(&board.pieces, i);
        for moved_piece in movements(piece) {
            if valid(&moved_piece, &area) {
                let mut new_board: Board = board.clone();
                replace(moved_piece, i, &mut new_board);
                potentials.push(new_board);
            }
        }
    }
    potentials
}

fn expand_layer(boards: &[Board], previous: &[Vec<Board>]) -> Vec<Board> {
    let mut potentials: Vec<Board> = vec!();
    let pboards: Vec<Vec<Board>> = boards.iter().map(|board| potential_boards(board)).collect();

    for mut boards in pboards {
        boards.retain(|b| (previous.iter().find(|pb| pb.contains(b)).is_none()));
        potentials.append(&mut boards);
    }
    potentials
}

fn main() {
    let now = Instant::now();
    let mut layer: Vec<Board> = vec!(initial_board());
    let mut layers: Vec<Vec<Board>> = vec!(layer.clone());
    let mut counter: usize = 0;
    loop {
        layer = expand_layer(&layer, &layers);
        // for board in &layer { show(&board); }
        println!("layer {} size: {} | {} s", layers.len(), layer.len(), now.elapsed().as_secs());
        layers.push(layer.clone());
        counter += 1;
        if counter > 10 {
            break;
        }
    }
}
