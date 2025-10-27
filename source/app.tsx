import React from 'react';
import {Text, Box, useInput, useApp} from 'ink';

type Props = {
	name: string | undefined;
};

export default function App({name = 'Stranger'}: Props) {
	const {exit} = useApp();

	useInput((input, key) => {
		// Выход по клавише 'q' или Ctrl+C
		if (input === 'q' || (key.ctrl && input === 'c')) {
			exit();
		}
	});

	return (
		<Box flexDirection="column" padding={1}>
			<Text>
				Hello, <Text color="green">{name}</Text>!
			</Text>
			<Text dimColor>
				{'\n'}Press <Text bold color="cyan">q</Text> or <Text bold color="cyan">Ctrl+C</Text> to exit
			</Text>
		</Box>
	);
}
