import {
  CreateDateColumn,
  DeleteDateColumn,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Every table in this system carries these four columns — CLAUDE.md §3.1–3.3.
 *
 * `deleted_at` is a TypeORM DeleteDateColumn, so repository finds exclude
 * soft-deleted rows automatically and `.softRemove()` / `.softDelete()` are the
 * only deletion paths. Never call `.delete()` / `.remove()`.
 */
export abstract class BaseEntity {
  @PrimaryGeneratedColumn('uuid')
  id!: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt!: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt!: Date;

  @DeleteDateColumn({ name: 'deleted_at', type: 'timestamptz', nullable: true })
  deletedAt!: Date | null;
}
