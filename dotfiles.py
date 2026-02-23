#!/bin/env python
'''Менеджер конфигурационных файлов
Копирует конфигурационные файлы в своё хранилище рекурсивно,
это каталог в котором находится этот сценарий.
Создает символические ссылки на них в соответствии с иерархией
каталогов из этого хранилища, относительно домашнего каталога пользователя.
Дата создания: 2026-02-19
'''
import os
import argparse

script_path = os.path.realpath(__file__)
dotfiles_path = os.path.dirname(script_path)
home_path = os.path.expanduser('~')

ignore_dirs = ['.git', '.ansible', 'etc']
ignore_files = [os.path.basename(script_path), 'askpass.sh']

def make_not_existing_dirs(path: str, args):
    if not os.path.exists(path):
        if args.verbose:
            print('Создаем каталоги по пути', path)
        if args.test:
            print('Должны быть создать каталоги по пути', path)
        else:
            os.makedirs(path)

def pull_files(args):
    '''Копирует указанный файл или каталог рекурсивно и заменяет
    на символические ссылки'''
    abs_path = os.path.expanduser(args.path)

    if not (abs_path.startswith('/') or args.path.startswith('~')):
        print('Можно указывать только пути относительно домашнего каталога', 
              'Например, ~/.config/nvim или /home/trac/.config', sep='\n')
        return

    if not os.path.exists(abs_path):
        print(f'Файла {abs_path} не существует.')
        return

    file_pathes = []

    if os.path.isdir(abs_path):
        for root, _, files in os.walk(abs_path):
            file_pathes.extend(os.path.join(root, file)
                               for file in files)
    else:
        file_pathes.append(abs_path)

    for src_path in file_pathes:
        dst_path = os.path.join(dotfiles_path,
                                src_path[len(home_path) + 1:])

        if os.path.islink(src_path):
            if args.verbose:
                print(f'Файл {src_path} является симлинком, пропускаем.')
            continue

        if os.path.exists(dst_path):
            print(f'Файл {dst_path} уже существует.')
            answer = input('Перезаписать? [y/n]: ').strip()
            if answer == 'n':
                continue
            else:
                if args.test:
                    print(f'Файл {dst_path} должен был быть удален.')
                else:
                    if args.verbose:
                        print('Удаляем файл', dst_path)
                    os.remove(dst_path)

        make_not_existing_dirs(os.path.dirname(dst_path), args)
        if args.test:
            print('Должны были переместить файл', src_path, 'в', dst_path,
                  'и создать символическую ссылку')
        else:
            if args.verbose:
                print(f'Перемещаем файл из {src_path} в {dst_path}')
            os.rename(src_path, dst_path)
            if args.verbose:
                print(f'Создаем символическую ссылку на {src_path} '
                      f'И помещаем ее в {dst_path}')
            os.symlink(dst_path, src_path)
            print(f'Файл {src_path} добавлен.')

def push_files(_):
    '''Создает символические ссылки на конфигурационные файлы'''
    for root, dirs, files in os.walk(dotfiles_path):
        dirs[:] = [d for d in dirs if d not in ignore_dirs]
        files[:] = [f for f in files if f not in ignore_files]

        for file in files:
            if os.path.relpath(root, dotfiles_path) == '.':
                src_path = os.path.join(dotfiles_path, file)
                dst_path = os.path.join(home_path, file)
            else:
                src_path = os.path.join(root, file)
                dst_path = os.path.join(home_path,
                                        root[len(dotfiles_path)+1:],
                                        file)

            if os.path.lexists(dst_path):
                if os.path.realpath(dst_path) == src_path:
                    if args.verbose:
                        print(f'Файл {dst_path} уже указывает на {src_path}',
                              'пропускаем')
                    continue
                if args.verbose:
                    print('Удаляем файл', dst_path)
                if args.test:
                    print('Должны были удалить файл', dst_path)
                else:
                    os.remove(dst_path)

            make_not_existing_dirs(os.path.dirname(dst_path), args)

            if args.verbose:
                print('Создаем символическую ссылку на', src_path,
                      'и помещаем файл в', dst_path)
            if args.test:
                print('Должны были создать ссылку на файл', src_path,
                      'в', dst_path)
            else:
                os.symlink(src_path, dst_path)
                print('Ссылка на файл', src_path.replace(home_path, '~'),
                      'Создана в', dst_path.replace(home_path, '~'),
                      sep=' ')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument('-t', '--test', action='store_true',
        help='Не выполнять фактические операции с файлами '
             'а только сообщать о них')

    parser.add_argument('-v', '--verbose', action='store_true',
        help='Выводить подробную информацию в процессе выполнения')

    subparsers = parser.add_subparsers(dest='command',
                                       help='Доступные команды')

    parser_pull = subparsers.add_parser('pull', help=pull_files.__doc__)
    parser_pull.add_argument('path', type=str,
        help='Путь к файлу или каталогу')
    parser_pull.set_defaults(func=pull_files)

    parser_push = subparsers.add_parser('push', help=push_files.__doc__)
    parser_push.set_defaults(func=push_files)

    args = parser.parse_args()
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()
